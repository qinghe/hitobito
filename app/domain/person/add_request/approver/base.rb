# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Person::AddRequest::Approver
  class Base

    attr_reader :request, :user

    def initialize(request, user)
      @request = request
      @current_user = user
    end

    def approve
      Person.transaction do
        if entity.save
          send_approval
          request.destroy
        end
      end
    end

    def reject
      Person.transaction do
        send_rejection unless user.id == request.requester_id
        request.destroy
      end
    end

    def entity
      @entity ||= build_entity
    end

    def error_message
      entity.errors.full_messages.join(', ')
    end

    private

    def send_approval
      Person::AddRequestMailer.
        approved(request.person, request.body, request.requester, user).
        deliver_later
    end

    def send_rejection
      Person::AddRequestMailer.
        rejected(request.person, request.body, request.requester, user).
        deliver_later
    end

    def build_entity
      fail(NotImplementedError)
    end

  end
end