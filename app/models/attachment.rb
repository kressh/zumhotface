class Attachment < ActiveRecord::Base

  SAFE_CHARS = (('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a + %w(- _ ~)).freeze

  belongs_to :user

  has_attached_file :file,
      hash_secret: Settings.attachments.secret_key,
      path: ":rails_root/public/system/attachments/:id_partition/:hash.:extension"
      #path: "/attachments/:id_partition/:hash.:extension"
  #,
      #url: ":s3_domain_url",
      #storage: :s3,
      #s3_credentials: Settings.attachments.aws_s3.s3_credentials,
      #bucket: Settings.attachments.aws_s3.bucket

  # skip content type validation
  validates_attachment_content_type :file, content_type: /.*/

  before_validation :set_unique_identifier

  #after_create :move_to_s3

  #def encrypt(passphrase)
  #end

private
  def set_unique_identifier
    begin
        self.sid = generate_identifier
    end while self.class.exists?(sid: self.sid)
  end

  def generate_identifier
    #TODO: limit to 17850625 unique combinations
    # so we should increase chars count later
    Array.new(4){ SAFE_CHARS.sample }.join
  end

end
