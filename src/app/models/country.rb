class Country < ApplicationRecord
  self.table_name = "countries"

  validates :name, allow_blank: false, uniqueness: true, presence: true
  validates :corruption_index, comparison: { greater_than: 0 }, numericality: { only_integer: true }, presence: true
  validates :annual_income, allow_nil: true, comparison: { greater_than_or_equal_to: 0 }
end
