class JwtService
  SECRET_KEY = Rails.application.secret_key_base

  def self.encode payload, exp = Settings.jwt.exp.hours.from_now
    payload[:exp] = exp.to_i
    JWT.encode payload, SECRET_KEY
  rescue StandardError => e
    Rails.logger.error I18n.t("jwt.encoding", message: e.message)
    nil
  end

  def self.decode token
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new body
  rescue JWT::DecodeError => e
    Rails.logger.error I18n.t("jwt.decoding", message: e.message)
    nil
  end
end
