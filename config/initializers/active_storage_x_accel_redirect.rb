# frozen_string_literal: true

module ActiveStorageXAccelRedirect
  def show
    # NOTE: Nginx側に /internal/active_storage (internal+alias) の定義が必要。
    # /rails/active_storage はRailsに到達させる。
    if (key = decode_verified_key)
      service = named_disk_service(key[:service_name])
      if use_x_accel_redirect?(service)
        path = service.path_for(key[:key])
        return head :not_found unless File.exist?(path)

        response.headers["X-Accel-Redirect"] = internal_path_for(key[:key])
        response.headers["Content-Type"] = key[:content_type] if key[:content_type].present?
        response.headers["Content-Disposition"] = key[:disposition] if key[:disposition].present?
        return head :ok
      end
    else
      return head :not_found
    end

    super
  rescue Errno::ENOENT
    head :not_found
  end

  private
    def use_x_accel_redirect?(service)
      Rails.configuration.x.active_storage.use_x_accel_redirect &&
        service.is_a?(ActiveStorage::Service::DiskService)
    end

    def internal_path_for(key)
      folder = [key[0..1], key[2..3]].join("/")
      "/internal/active_storage/#{folder}/#{key}"
    end
end

ActiveStorage::DiskController.prepend(ActiveStorageXAccelRedirect)
