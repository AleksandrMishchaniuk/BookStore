# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # storage :file
  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process resize_to_fit: [1000, 1000]

  version :thumb do
    process resize_to_fit: [200, 200]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
