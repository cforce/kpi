class KpiImportedValuesController < ApplicationController
    before_filter :authorized_globaly?

    helper :kpi
    include KpiHelper

    def permission_titles
        @titles = UserTitle.joins(:department_title_relations).order(:name).where("#{DepartmentTitleRelation.table_name}.user_department_id = ? ", params[:id])
        respond_to do |format|
          format.js {
            render "permission_titles_select_box"
            }
        end
    end

    def new
        find_date
        @value = KpiImportedValue.new
        render "new", :layout => false
    end

    def create
    @value = KpiImportedValue.new(params[:kpi_imported_value])
    @value.save

    find_values
    respond_to do |format|
        format.js { render 'form'}
        end   
    end

    def destroy
        @value = KpiImportedValue.find(params[:id])
        @value.destroy
        redirect_to :action => 'edit_values', "date[month]" => params[:date][:month], "date[year]" => params[:date][:year]
    end

    def update_values

    params[:imported_value].each do |id, imported_value|
        month_value = KpiImportedMonthValue.find_or_create_by_kpi_imported_value_id_and_date(id, params[:full_date])
        month_value.plan_value = imported_value['plan_value']
        month_value.fact_value = imported_value['fact_value']
        month_value.save
    end
=begin
        @values = KpiImportedValue.order("name");
        @values.each{|value|
            if not params[:imported_value][value.id.to_s].nil?
                value.plan_value=params[:imported_value][value.id.to_s]['plan_value']
                value.fact_value=params[:imported_value][value.id.to_s]['fact_value']
                value.save
            end
            }
=end
        find_values
        respond_to do |format|
            format.js { render 'form'}
        end
    end

    def edit_values
        find_values
    end

    private 
    def find_date
        @date = Date.today.at_beginning_of_month
        @date = Date.parse("1/#{params[:date][:month]}/#{params[:date][:year]}") unless params[:date].nil?
        @date = Date.parse("#{params[:full_date]}") unless params[:full_date].nil?
    end

    def find_values
    find_date

        @values = KpiImportedValue.joins("LEFT OUTER JOIN #{KpiImportedMonthValue.table_name} ON #{KpiImportedMonthValue.table_name}.kpi_imported_value_id = #{KpiImportedValue.table_name}.id 
                                    AND #{KpiImportedMonthValue.table_name}.date = '#{@date.year}-#{@date.month}-#{@date.day}'")
                                  .select("#{KpiImportedMonthValue.table_name}.*, #{KpiImportedValue.table_name}.*")                            
                                  .order("name");

    end

end