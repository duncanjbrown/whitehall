module SyncChecker
  DRAFT_CONTENT_STORE = 'draft-content-store'
  LIVE_CONTENT_STORE = 'content-store'

  class RequestQueue
    attr_reader :request_type, :requests
    def initialize(document_check, failure_result_set)
      @requests = []
      document_check.base_paths[:draft].each do |locale, path|
        requests << draft_request = Typhoeus::Request.new(
          request_url(path, DRAFT_CONTENT_STORE)
        )
        draft_request.on_complete do |response|
          result = document_check.check_draft(response, locale)
          failure_result_set << result
        end
      end

      document_check.base_paths[:live].each do |locale, path|
        requests << live_request = Typhoeus::Request.new(
          request_url(path, LIVE_CONTENT_STORE)
        )
        live_request.on_complete do |response|
          result = document_check.check_live(response, locale)
          failure_result_set << result
        end
      end
    end

  private

    def request_url(base_path, content_store)
      File.join(Plek.find(content_store), "content", base_path)
    end
  end
end
