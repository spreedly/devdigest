class Devdigest
  def initialize(since, options={})
    @since  = since
    @digest = ""
    @only   = options[:only]
  end

  def run
    run_github_digest
    @digest
  end

  def add(row)
    @digest << "#{row}\n"
  end

  def skip?(section)
    @only && !@only.include?(section)
  end

  def run_github_digest
    return unless %w{GITHUB_ORG GITHUB_TOKEN}.all? {|key| ENV.has_key?(key)}
    return if skip?("github")

    ENV['GITHUB_ORG'].split(',').sort.each { |org|
      gh_worker = Dd::Gh.new(ENV['GITHUB_TOKEN'], org, @since)
      gh_digest = gh_worker.run
      add(gh_digest)
    }

  rescue => e
    add e.to_s
    e.backtrace.each { |line| add('  ' + line) }
  end
end
