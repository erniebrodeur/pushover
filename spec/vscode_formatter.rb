class VsCodeFormatter
  RSpec::Core::Formatters.register self, :message, :dump_summary, :dump_failures, :dump_pending, :seed

  def initialize(output)
    @output = output
  end

  def message(notification)
    @output << notification.message
  end

  def dump_failures(notification)
    return if notification.failure_notifications.empty?

    notification.failed_examples.each { |e| @output << "error: #{e.full_description} @ #{e.location}" << "\n" }
  end

  def dump_summary(summary); end

  def dump_pending(notification)
    return if notification.pending_examples.empty?

    notification.pending_examples.each { |e| @output << "warning: #{e.full_description} @ #{e.location}" << "\n" }
  end

  def seed(notification)
    return unless notification.seed_used?

    @output << notification.fully_formatted
  end
end
