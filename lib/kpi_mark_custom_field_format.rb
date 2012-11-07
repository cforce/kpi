class KpiMarkCustomFieldFormat < Redmine::CustomFieldFormat

    def format_as_kpi_mark(value)
        return KpiIssueMark.where(:value => value).first.title
    end

    def edit_as
        'kpi_mark'
    end    
end
