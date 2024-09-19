# frozen_string_literal: true

class WikiPagePolicy < BasePolicy
  delegate { @subject.wiki.container }

  rule { can?(:read_wiki) }.policy do
    enable :read_wiki_page
    enable :create_note
  end
end
