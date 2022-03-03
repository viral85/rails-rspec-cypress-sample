class ShareLinkReflex < ApplicationReflex
  def toggle_sharing(is_enabled)
    @panel = current_user.panel
    is_enabled == "true" ? @panel.enable_sharing : @panel.disable_sharing
    morph_modal
  end

  def reset_share_token
    current_user.panel.reset_share_token
    morph_modal
  end

  private

  def morph_modal
    morph "#share_modal", render(partial: "users/pages/share_link/share_link_modal",
                                 locals: { user: current_user })
  end
end
