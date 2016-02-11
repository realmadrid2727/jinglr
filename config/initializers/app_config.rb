yml = YAML.load_file("#{Rails.root}/config/app_config.yml")
APP_CONFIG = yml['default']
APP_CONFIG.merge!(yml[Rails.env]) unless yml[Rails.env].nil?
APP_CONFIG.freeze
