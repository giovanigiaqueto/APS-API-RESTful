class ChangeAnnualIncomeInCountries < ActiveRecord::Migration[7.0]
  def change
    change_column_null :countries, :annual_income, true
  end
end
