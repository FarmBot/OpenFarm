# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :stage_action do
    name             { "#{Faker::Name.last_name}" }
    overview         { Faker::Lorem.paragraph }
  end
end
