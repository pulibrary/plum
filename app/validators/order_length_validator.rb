class OrderLengthValidator < ActiveModel::Validator
  def validate(record)
    length_validator(record.proxy_length).validate(record)
  end

  private

    def length_validator(length)
      ActiveModel::Validations::LengthValidator.new(
        attributes: [:order],
        is: length,
        message: "given has the wrong number of elements (should be #{length})"
      )
    end
end
