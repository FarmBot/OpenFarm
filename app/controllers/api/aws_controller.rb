module Api
  # A controller that handles all the non-restful stuff for AWS.
  class AwsController < Api::Controller
    def s3_access_token
      render json: {
        policy:    s3_upload_policy,
        signature: s3_upload_signature,
        key:       ENV['S3_ACCESS_KEY']
      }
    end

    private

    def s3_upload_policy
      @p ||= Base64.encode64(
        { 'expiration' => 1.hour.from_now.utc.xmlschema,
          'conditions' => [
            { 'bucket' =>  ENV['S3_BUCKET_NAME'] },
            ['starts-with', '$key', ''],
            { 'acl' => 'public-read' },
            { success_action_status: '201' },
            ['starts-with', '$Content-Type', ''],
            ['content-length-range', 1, 2 * 1024 * 1024]
          ] }.to_json).gsub(/\n/, '')
    end

    def s3_upload_signature
      # Notice the gsub("\n", ''). Holy cow you will be frustrated if you forget
      # to strip out the carriage return. AWS gives cryptic errors.
      Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'),
                                           ENV['S3_SECRET_KEY'],
                                           s3_upload_policy)).gsub("\n", '')
    end
  end
end
