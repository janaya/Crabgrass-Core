module Assets::TagsHelper

  def remove_tag_link(tag)
    link = link_to_remote(
      :remove.t,
      {
        :url      => destroy_asset_tag_path(@asset, tag),
        :method   => :delete,
        :complete => hide("tag_#{tag.id}")
      },
      { :class => 'shy inline', :icon => 'tiny_trash'}
    )
    content_tag(:div, :id => "tag_#{tag.id}", :class => 'shy_parent p') do
      content_tag(:span, h(tag.name), :class => 'icon tag_16 inline') + ' ' +
      link
    end
  end

  def options_for_edit_tag_form
    [{
      :method   => :post,
      :asset_id => @asset.id,
      :html     => {:id => 'edit_tag_form'},
      :loading  => show_spinner('tag')
    }]
  end

end
