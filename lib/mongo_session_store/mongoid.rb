require 'mongoid'

module ActionDispatch
  module Session
    class MongoidStore < AbstractStore

      class Session
        include Mongoid::Document
        include Mongoid::Timestamps

        field :data, :type => Hash, :default => {}
        index :updated_at
      end

      # The class used for session storage.
      cattr_accessor :session_class
      self.session_class = Session

      SESSION_RECORD_KEY = 'rack.session.record'.freeze

      private
        def generate_sid
          Mongo::ObjectID.new
        end

        def get_session(env, sid)
          sid ||= generate_sid
          session = find_session(sid)
          env[SESSION_RECORD_KEY] = session
          [sid, HashWithIndifferentAccess.new(session.data)]
        end

        def set_session(env, sid, session_data)
          record = env[SESSION_RECORD_KEY] ||= find_session(sid)
          record.data = session_data
          #per rack spec: Should return true or false dependant on whether or not the session was saved or not.
          record.save ? true : false
        end

        def find_session(id)
          @@session_class.first(:conditions => { :_id => id }) ||
            @@session_class.new(:id => id)
        end
    end
  end
end
