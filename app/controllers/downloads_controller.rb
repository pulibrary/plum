class DownloadsController < ApplicationController
  include CurationConcerns::DownloadBehavior

  protected

    def authorize_download!
      case params[:file]
      when "gray-pdf"
        authorize! :pdf, asset
      when "color-pdf"
        authorize! :color_pdf, asset
      else
        authorize! :download, asset
      end
    end

  private

    def load_file
      file_reference = params[:file]
      return default_file unless file_reference

      file_path = PairtreeDerivativePath.derivative_path_for_reference(asset, file_reference)
      File.exist?(file_path) ? file_path : nil
    end

    def default_file
      File.exist?(asset.local_file) ? asset.local_file : super
    end
end
