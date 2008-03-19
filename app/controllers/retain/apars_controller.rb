module Retain
  class AparsController < RetainController
    def show
      group_request = [
                       :apar_fix_component,
                       :apar_fix_component_name,
                       :apar_problem_summary,
                       :problem_error_description,
                       :apar_abstract
                      ]
      options = {
        :apar_number => params[:id],
        :group_request => group_request
      }
      @apar = Retain::Apar.new(options)
    end
  end
end
