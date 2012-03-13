#require 'base64'
require 'base64'
require 'openssl'
require 'digest/sha1'


class S3UploadsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :login_required, [:only => "index"]
  #include S3SwfUpload::Signature
  def index
    bucket          = s3_bucket
    access_key_id   = S3Config.access_key_id
    key             = params[:key]
    content_type    = params[:content_type]
    file_size       = params[:file_size]
    acl             = S3Config.acl
    https           = 'false'
    expiration_date = 1.hours.from_now.strftime('%Y-%m-%dT%H:%M:%S.000Z')

    max_file_size = S3Config.max_file_size
    max_file_MB   = (max_file_size/1024/1024).to_i

    error_message   = "Selected file is too large (max is #{max_file_MB}MB)" if file_size.to_i > S3Config.max_file_size

    policy = Base64.encode64(
"{
    'expiration': '#{expiration_date}',
    'conditions': [
        {'bucket': '#{bucket}'},
        {'key': '#{key}'},
        {'acl': '#{acl}'},
        {'Content-Type': '#{content_type}'},
        ['starts-with', '$Filename', ''],
        ['eq', '$success_action_status', '201']
    ]
}").gsub(/\n|\r/, '')

    #signature = b64_hmac_sha1(S3SwfUpload::S3Config.secret_access_key, policy)
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'),S3Config.secret_access_key, policy)).gsub("\n","")
    respond_to do |format|
      format.xml {
        render :xml => {
          :policy          => policy,
          :signature       => signature,
          :bucket          => bucket,
          :accesskeyid     => access_key_id,
          :acl             => acl,
          :expirationdate  => expiration_date,
          :https           => https,
          :errorMessage    => error_message.to_s
        }.to_xml
      }
    end
  end
end