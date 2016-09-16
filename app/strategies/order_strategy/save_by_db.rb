class OrderStrategy::SaveByDb < OrderStrategy::SaveBase

  def save(order)
    prepare_save(order)
    raise 'You should inplement method #save'
  end

end
