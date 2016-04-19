class TokenService
  def self.new_token(key, user, expires = 3600)
    time = Time.now.to_i + expires
    nonce = rand(2**64)
    openssl = OpenSSL::Cipher::AES.new(128, :CBC)
    openssl.encrypt
    openssl.key = key
    openssl.iv = nonce.to_s
    encrypted = openssl.update("#{user.email}_#{time}") + openssl.final
    Base64.encode64("#{nonce}_#{encrypted}").chomp
  end

  def self.user_from_token(key, token)
    decoded = Base64.decode64(token).split('_')
    return nil unless decoded.length == 2
    cipher2 = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher2.decrypt
    cipher2.key = key
    cipher2.iv = decoded[0]
    decrypted = (cipher2.update(decoded[1]) + cipher2.final).split('_', 2)
    return User.where(email: decrypted[0]).first if decrypted[1].to_i > Time.now.to_i
  rescue
    nil
  end
end
