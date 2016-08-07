module BeforeAfterActionsSharedExamples
  shared_examples 'calls :save_order_in_progress method' do
    it 'calls :save_order_in_progress method' do
      expect(controller).to receive(:save_order_in_progress)
      query
    end
  end
  shared_examples 'calls :check_order method' do
    it 'calls :chek_order method' do
      expect(controller).to receive(:check_order)
      query
    end
  end
  shared_examples 'does not call :check_order method' do
    it 'calls :chek_order method' do
      expect(controller).to_not receive(:check_order)
      query
    end
  end
  shared_examples 'calls :check_step! method' do
    it 'calls :check_step! method' do
      expect(controller).to receive(:check_step!)
      query
    end
  end
end
