module HasAttachment
  extend ActiveSupport::Concern

  included do
    # Set proper content type for octet-streams
    before_validation on: :create do
      if file_content_type == 'application/octet-stream'
        mime_type = MIME::Types.type_for(file_file_name)
        self.file_content_type = mime_type.first.content_type if mime_type.first
      end
    end

    has_attached_file :file,
      hash_secret: Settings.uploads.secret_key,
      hash_data: 'uploads/file/:id/:style/:updated_at',
      url: '/static/uploads/:id_partition/:hash.:extension',
      path: "#{Settings.uploads.directory}:url",
      escape_url:      false,
      use_timestamp:   false,
      styles: {
        icon: "64x64^",
        thumb: "150x150^" },
      convert_options: {
        icon: "-gravity center -extent 64x64",
        thumb: "-gravity center -extent 150x150" }


    # TODO: move to s3
    # path: "/uploads/:id_partition/:hash.:extension",
    # url: ":s3_domain_url",
    # storage: :s3,
    # s3_credentials: Settings.uploads.aws_s3.s3_credentials,
    # bucket: Settings.uploads.aws_s3.bucket

    do_not_validate_attachment_file_type :file

    # TODO: delayed_paperclip
    #process_in_background :file,
      #processing_image_url: "/i/loader.gif"

    before_post_process :skip_for_non_image
  end

  def skip_for_non_image
    image?
  end

  def image?
    file? && file.content_type.include?('image')
  end
end
