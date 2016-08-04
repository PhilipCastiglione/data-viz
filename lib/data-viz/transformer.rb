require "json"
require "csv"

class Transformer
  HEADERS = %w(Date Task Hours).freeze

  attr_accessor :raw_tasks, :tasks, :raw_entries, :entries

  def generate_csv
    raise ArgumentError if raw_tasks.nil? || raw_entries.nil?

    build_task_hash
    clean_up_entries

    CSV.open("./csv/#{Date.today.strftime("%Y%m%d")}.csv", "wb") do |csv|
      csv << HEADERS
      rows.each { |r| csv << r }
    end
  end

  private

  # transforms array of hashes with value of hash we care about, to a hash
  def build_task_hash
    self.tasks = JSON.parse(raw_tasks).reduce({}) do
      |h, t| h.merge({ t["task"]["id"] => t["task"]["name"] })
    end
  end

  # transforms array of hashes with value we care about, to array of hashes
  def clean_up_entries
    self.entries = JSON.parse(raw_entries).map(&:values).flatten
  end

  # the csv files are small so i do what i want ok
  def rows
    @rows ||= extract_rows_from(entries)
  end

  # just get the bits we care about, and transform to csv
  def extract_rows_from(entries)
    entries.map do |e|
      [
        e["spent_at"],
        tasks[e["task_id"]],
        e["hours"]
      ]
    end
  end
end
