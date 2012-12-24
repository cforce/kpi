class KpiImportedValuesController < ApplicationController
    before_filter :authorized_globaly?

    def new
        @value = KpiImportedValue.new
        render "new", :layout => false
    end

    def create
    @value = KpiImportedValue.new(params[:kpi_imported_value])
    @value.save

    @values = KpiImportedValue.order("name");
    respond_to do |format|
        format.js {
            render(:update) {|page|
            page.replace_html "imported_values_form", :partial => 'kpi_imported_values/form'
            }
        }
        end   
    end

    def destroy
        @value = KpiImportedValue.find(params[:id])
        @value.destroy
        redirect_to :action => 'edit_values'
    end

    def update_values
        @values = KpiImportedValue.order("name");
        @values.each{|value|
            if not params[:imported_value][value.id.to_s].nil?
                value.plan_value=params[:imported_value][value.id.to_s]['plan_value']
                value.fact_value=params[:imported_value][value.id.to_s]['fact_value']
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