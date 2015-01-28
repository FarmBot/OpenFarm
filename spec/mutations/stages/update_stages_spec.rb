require 'spec_helper'

describe Stages::UpdateStage do
  let(:mutation) { Stages::UpdateStage }

  let(:stage) { FactoryGirl.create(:stage) }

  let(:params) do
    { user: stage.guide.user,
      stage: stage,
      attributes: {} }
  end

  it 'requires fields' do
    errors = mutation.run({}).errors.message_list
    expect(errors).to include('User is required')
    expect(errors).to include('Stage is required')
  end

  it 'minimally requires a user and a stage' do
    expect(mutation.run(params).success?).to be_truthy
  end

  it 'updates a stage image via URL' do
    VCR.use_cassette('mutations/stages/update_stage') do
      image_hash = {
        image_url: 'http://i.imgur.com/2haLt4J.jpg'
      }
      image_params = params.merge(images: [image_hash])
      results = mutation.run(image_params)
      pics = results.result.pictures
      expect(pics.count).to eq(1)
    end
  end

  it 'disallows phony URLs' do
    image_hash = {
      image_url: 'iWroteThisWrong.net/2haLt4J.jpg'
    }
    image_params = params.merge(images: [image_hash])
    results = mutation.run(image_params)
    expect(results.success?).to be_falsey
    expect(results.errors.message[:images]).to include('not a valid URL')
  end

  it 'allows an empty stage actions array' do
    actions_params = params.merge(actions: [])
    results = mutation.run(actions_params)
    expect(results.success?).to be_truthy
  end

  it 'allows a well formed stage actions array' do
    actions = [{ name: "#{Faker::Lorem.word}",
                 overview: "#{Faker::Lorem.paragraph}" }]
    actions_params = params.merge(actions: actions)
    results = mutation.run(actions_params)
    expect(results.success?).to be_truthy
    expect(results.result.stage_actions.length).to eq(1)
  end

  it 'disallows a badly formed stage actions array with bad overview' do
    actions = [{ name: "#{Faker::Lorem.word}",
                 description: "#{Faker::Lorem.paragraph}" }]
    actions_params = params.merge(actions: actions)
    results = mutation.run(actions_params)
    expect(results.success?).to be_falsey
    expect(results.errors.message[:actions]).to include('valid overview')
  end

  it 'disallows a badly formed stage actions array with bad name' do
    actions = [{ moon: "#{Faker::Lorem.word}",
                 overview: "#{Faker::Lorem.paragraph}" }]
    actions_params = params.merge(actions: actions)
    results = mutation.run(actions_params)
    expect(results.success?).to be_falsey
    expect(results.errors.message[:actions]).to include('valid name')
  end

  it 'deletes images marked for deletion' do
    VCR.use_cassette('mutations/stages/update_stage') do
      image_hash = [{ image_url: 'http://i.imgur.com/2haLt4J.jpg' }]

      image_params = params.merge(images: image_hash)
      mutation.run(image_params)

      image_hash = []

      image_params[:images] = image_hash

      results = mutation.run(image_params)
      pics = results.result.pictures
      expect(pics.count).to eq(0)
    end
  end

  it 'does not edit existing images' do
    VCR.use_cassette('mutations/stages/update_stage') do
      image_hash = [{ image_url: 'http://i.imgur.com/2haLt4J.jpg' }]

      image_params = params.merge(images: image_hash)
      mutation.run(image_params)

      stage.reload

      image_hash = [{ image_url: 'http://i.imgur.com/2haLt4J.jpg',
                      id: stage.pictures.first.id },
                    { image_url: 'http://i.imgur.com/kpHLl.jpg' }]

      image_params[:images] = image_hash

      results = mutation.run(image_params)
      expect(results.success?).to be_falsey
      expect(results.errors.message[:images]).to include('existing image')
    end
  end
end
