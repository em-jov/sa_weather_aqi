require_relative '../test_helper'

class ExceptionNotifierTest < TestCase
  def test_notify
    exception = Exception.new("error")
    exception.set_backtrace(["line1", "line2"])
    Logger.any_instance.expects(:error).with("error")
    Logger.any_instance.expects(:error).with("line1\nline2")
    Sentry.expects(:capture_exception).with(exception)
    ExceptionNotifier.notify(exception)
  end
end