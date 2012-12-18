class KpiImportedValuesController < ApplicationController
    before_filter :authorized_globaly?


    def update_values
        @values = KpiImportedValue.order("name");
        @values.each{|value|
            if not params[:imported_value][value.id.to_s].nil?
                value.value=params[:imported_value][value.id.to_s]
                value.save
            end
            }


        respond_to do |format|
          format.html { redirect_to :controller => 'imported_values_form', :action => 'edit_values'}
          format.js {
            render(:update) {|page|
              page.replace_html "imported_values_form", :partial => 'kpi_imported_values/form'
            }
          }
        end
    end

    def edit_values
        @values = KpiImportedValue.order("name");
    end

end