module Retain
  class Pmr < Base
    set_fetch_request "PMPB"
    set_fetch_required_fields(:problem, :branch, :country
                              :signon, :password,
                              :pmpb_group_request)
  end
end
