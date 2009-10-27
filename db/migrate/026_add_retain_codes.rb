# -*- coding: utf-8 -*-

class AddRetainCodes < ActiveRecord::Migration
  def self.up
    Retain::ServiceGivenCode.create(:service_given => 19,
                                    :description => "Code Defect (19)")
    Retain::ServiceGivenCode.create(:service_given => 29,
                                    :description => "Non Code Defect (3rd party or hardware) (29)")
    Retain::ServiceGivenCode.create(:service_given => 39,
                                    :description => "Usage, How-To, Setup, Configure (39)")
    Retain::ServiceGivenCode.create(:service_given => 49,
                                    :description => "Installation (49)")
    Retain::ServiceGivenCode.create(:service_given => 89,
                                    :description => "Customer does not wish to pursue (89)")
    Retain::ServiceGivenCode.create(:service_given => 99,
                                    :description => "No resolution given (99)")
    Retain::ServiceActionCauseTuple.create(:psar_service_code => 72,
                                           :psar_action_code => 27,
                                           :psar_cause => 21,
                                           :apar_required => true,
                                           :description => "Newly discovered defect (72, 27, 21)")
    Retain::ServiceActionCauseTuple.create(:psar_service_code => 75,
                                           :psar_action_code => 57,
                                           :psar_cause => 51,
                                           :apar_required => false,
                                           :description => "Usage, How-To (75, 57, 51)")
#     Retain::ServiceActionCauseTuple.create(:psar_service_code => 68,
#                                            :psar_action_code => 80,
#                                            :psar_cause => 82,
#                                            :apar_required => true,
#                                            :description => "Known defect (rediscover) (68, 80, 82)")
    Retain::SolutionCode.create(:psar_solution_code => 4,
                              :description => "Did not request relief (4)")
    Retain::SolutionCode.create(:psar_solution_code => 5,
                              :description => "No relief is available for problem (5)")
    Retain::SolutionCode.create(:psar_solution_code => 6,
                              :description => "Customer unprepared to work problem (6)")
    Retain::SolutionCode.create(:psar_solution_code => 7,
                              :description => "Relief provided is inadequate (7)")
    Retain::SolutionCode.create(:psar_solution_code => 8,
                              :description => "Customer must recreate problem (8)")
    Retain::SolutionCode.create(:psar_solution_code => 9,
                              :description => "Customer received relief (9)")
  end

  def self.down
    [ 19, 29, 39, 49, 89, 99 ].each do |sg_code|
      sg = Retain::ServiceGivenCode.find_by_service_given(sg_code)
      sg.destroy if sg
    end
    ac = Retain::ServiceActionCauseTuple.find(:first,
                                              :conditions => {
                                                :psar_service_code => 72,
                                                :psar_action_code => 27,
                                                :psar_cause => 21 })
    ac.destroy if ac
    ac = Retain::ServiceActionCauseTuple.find(:first,
                                              :conditions => {
                                                :psar_service_code => 75,
                                                :psar_action_code => 57,
                                                :psar_cause => 51 })
    ac.destroy if ac
    ac = Retain::ServiceActionCauseTuple.find(:first,
                                              :conditions => {
                                                :psar_service_code => 68,
                                                :psar_action_code => 80,
                                                :psar_cause => 82 })
    ac.destroy if ac
    [ 4, 5, 6, 7, 8, 9 ].each do |solution_code|
      ic = Retain::SolutionCode.find_by_psar_solution_code(solution_code)
      ic.destroy if ic
    end
  end
end
