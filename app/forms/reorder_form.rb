class ReorderForm
  include ActiveModel::Model
  attr_accessor :order
  attr_reader :curation_concern
  validates_with OrderLengthValidator

  def initialize(curation_concern)
    @curation_concern = curation_concern
    @order = curation_concern.ordered_member_ids
  end

  def save
    if valid?
      apply_order && curation_concern.save
    else
      false
    end
  end

  def proxy_length
    curation_concern.ordered_member_ids.length
  end

  private

    def apply_order
      curation_concern.ordered_member_proxies.each_with_index do |proxy, index|
        proxy.proxy_for = ActiveFedora::Base.id_to_uri(order[index])
      end
      curation_concern.list_source.order_will_change!
    end
end
