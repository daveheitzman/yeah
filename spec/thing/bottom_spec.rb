describe Thing, '#bottom' do
  it { subject.bottom.should eq 0 }

  context "with area" do
    before do
      subject.area = Area.new
      subject.position = V[10, 10, 10]
      subject.size = V[4, 2, 8]
    end

    it "is y of bottom edge within area based on anchor" do
      subject.anchor[1] = 0
      subject.bottom.should eq 10

      subject.anchor[1] = 1
      subject.bottom.should eq 12

      subject.anchor[1] = 0.5
      subject.bottom.should eq 11
    end
  end
end