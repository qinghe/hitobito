require 'spec_helper'
describe Event::ParticipationDecorator, :draper_with_helpers do
  include Rails.application.routes.url_helpers

  let(:course) do
    event = Fabricate(:course, kind: event_kind)
    event.dates.create!(start_at: quali_date, finish_at: quali_date)
    event
  end

  let(:participation) do
    participation = Fabricate(:event_participation, event: course)
    Fabricate(participant_role.name.to_sym, participation: participation)
    participation
  end
  let(:quali_date)       { Date.new(2012, 10, 20) }
  let(:event_kind)       { event_kinds(:slk) }
  let(:decorator)        { Event::ParticipationDecorator.new(participation) }
  let(:participant_role) { Event::Role::Leader }
  let(:group)            { groups(:top_group) }

  { issue_action: [[nil, :active], [true, :inactive], [false, :active]],
    revoke_action: [[nil, :active], [true, :active], [false, :inactive]] }.each do |action, values|

    context "##{action}" do
      let(:node) { Capybara::Node::Simple.new(decorator.send(action, group)) }
      let(:icon) { node.find('i') }
      let(:link) { node.find('a') }

      values.each do |qualified, state|
        it "is #{state} if participation.qualified is #{qualified.nil? ? 'nil' : qualified}" do
          participation.update_column(:qualified, qualified)
          case state
          when :active then
            expect(link).to be_present
            expect(link[:title]).to match(/^Markiert Kurs/)
            expect(icon).to be_present
            expect(icon[:class]).to match(/disabled/)
          when :inactive then
            expect { expect(link).to }.to raise_error Capybara::ElementNotFound
            expect(icon).to be_present
            expect(icon[:class]).not_to match(/disabled/)
          end
        end
      end
    end
  end
end
