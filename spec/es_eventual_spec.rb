require "#{File.dirname __FILE__}/spec_helper"
require 'eventual'

describe Eventual, 'Es' do
  before do
    Date.stub!(:today).and_return Date.civil(2010)
  end

  describe 'proxy' do
    it "should raise NotImplementedError if using not implemented language" do
      lambda { Eventual.parse 'marzo', :lang => 'WP' }.should raise_error(NotImplementedError)
    end
  end

  shared_examples_for 'correctly parses dates' do
    it { @result.should_not be_nil }
    it { @result.to_a.size.should == @dates.map.size }
    it { @result.should map_dates *@dates }
  end
  
  shared_examples_for 'correctly parses time ranges' do
    it { @result.should_not be_nil }
    it { @result.to_a.size.should == @ranges.map.size }
    it { @result.should map_dates *@ranges }
  end

  shared_examples_for 'includes corresponding dates' do
    it { @dates.map{ |date| @result.should include(date) } }
    it { @result.should_not include(@dates.first - 1) }
    it { @result.should_not include(@dates.last + 1) }
    it { @dates.select{ |d| @result.include? d }.map{ |d| d.to_s  }.should == @dates.map{ |r| r.to_s  } }
  end

  describe 'month' do
    describe "month without year parsing 'marzo'" do
      before do
        @result = Eventual.parse 'marzo', :lang => 'Es'
        @dates  = (Date.parse('2010-3-1')..Date.parse('2010-3-31')).map
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end

    describe "month without year parsing 'marzo', case insensitive" do
      before do
        @result = Eventual.parse 'MarZo', :lang => 'Es'
        @dates  = (Date.parse('2010-3-1')..Date.parse('2010-3-31')).map
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end

    describe 'month with year' do
      describe "parsing 'marzo de 2009'" do
        before do
          @result = Eventual.parse "marzo de 2009"
          @dates  = (Date.parse('2009-3-1')..Date.parse('2009-3-31')).map
        end  
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "parsing 'marzo del 2009'" do
        before do
          @result = Eventual.parse "marzo del 2009"
          @dates  = (Date.parse('2009-3-1')..Date.parse('2009-3-31')).map
        end  
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "parsing 'marzo 2009'" do
        before do
          @result = Eventual.parse "marzo 2009"
          @dates  = (Date.parse('2009-3-1')..Date.parse('2009-3-31')).map
        end  
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "parsing 'marzo, 2009'" do
        before do
          @result = Eventual.parse "marzo, 2009"
          @dates  = (Date.parse('2009-3-1')..Date.parse('2009-3-31')).map
        end  
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "parsing 'marzo '09'" do
        before do
          @result = Eventual.parse "marzo '09"
          @dates  = (Date.parse('2009-3-1')..Date.parse('2009-3-31')).map
        end  
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end
    end

    describe 'month with wdays' do
      before do
        @dates = (Date.parse('2010-3-1')..Date.parse('2010-3-31')).reject{ |day| not [1,2].include?(day.wday) }
      end

      describe "parsing 'lunes y martes marzo del 2010'" do
        before { @result = Eventual.parse "lunes y martes marzo del 2010" }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "parsing 'lunes y martes de marzo del 2010'" do
        before { @result = Eventual.parse "lunes y martes de marzo del 2010" }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "parsing 'lunes y martes durante marzo del 2010'" do
        before { @result = Eventual.parse "lunes y martes durante marzo del 2010" }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "parsing 'lunes y martes durante todo marzo del 2010'" do
        before { @result = Eventual.parse "lunes y martes durante todo marzo del 2010" }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "parsing 'lunes y martes, marzo de 2010'" do
        before { @result = Eventual.parse "lunes y martes, marzo del 2010" }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end
    end

  end

  describe 'day numbers' do
    describe 'single date' do
      before do
        @dates = [Date.civil 2010, 3, 21]
      end

      describe "should single day number for '21 de marzo'" do
        before { @result = Eventual.parse("21 de marzo") }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "parsing '21 marzo'" do
        before { @result = Eventual.parse("21 marzo") }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      # describe "parsing 'marzo 21'" do
      #   before { @result = Eventual.parse("21 marzo") }
      #   it_should_behave_like 'correctly parses dates'
      #   it_should_behave_like 'includes corresponding dates'
      # end

      describe 'date with wday' do
        describe "parsing 'domingo 21 de marzo'" do
          before { @result = Eventual.parse("domingo 21 de marzo") }
          it_should_behave_like 'correctly parses dates'
          it_should_behave_like 'includes corresponding dates'
        end

        it "should raise WdayMatchError if weekday doesn't correspond to date" do
          lambda { Eventual.parse("lunes 21 de marzo").map }.should raise_error(Eventual::WdayMatchError)
        end
      end

      describe 'date with wday and comma' do
        describe "parsing 'domingo, 21 de marzo'" do
          before { @result = Eventual.parse("domingo, 21 de marzo") }
          it_should_behave_like 'correctly parses dates'
          it_should_behave_like 'includes corresponding dates'
        end

        it "should raise WdayMatchError if weekday doesn't correspond to date" do
          lambda { Eventual.parse("lunes 21 de marzo").map }.should raise_error(Eventual::WdayMatchError)
        end
      end
    end

    describe 'day list' do
      before do
        @dates = (1..3).map{ |i| Date.civil( 2010, 3, i) }
      end

      describe "day list for '1, 2 y 3 de marzo'" do
        before { @result = Eventual.parse("1, 2 y 3 marzo") }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "day list for '1, 2 y 3 marzo'" do
        before { @result = Eventual.parse("1, 2 y 3 de marzo") }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "day list with weekday 'lunes 1, martes 2 y miércoles 3 de marzo'" do
        before { @result = Eventual.parse("lunes 1, martes 2 y miércoles 3 de marzo") }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      it "should raise WdayMatchError if weekday doesn't correspond to date" do
        lambda { Eventual.parse("lunes 2, martes 2 y jueves 3 de marzo").map }.should raise_error(Eventual::WdayMatchError)
      end
    end
  end

  describe 'day range' do
    describe 'period in same month' do
      before do
        @dates = (1..3).map{ |i| Date.civil( 2010, 3, i) }
      end

      describe "day list for '1 al 3 de marzo" do
        before { @result = Eventual.parse("1 al 3 de marzo del '10") }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "day list for '1 al 3, marzo" do
        before { @result = Eventual.parse("1 al 3, marzo del '10") }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "day list for 'del 1 al 3 de marzo" do
        before { @result = Eventual.parse("del 1 al 3 de marzo del '10") }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "day list for 'del 1 al 3, marzo" do
        before { @result = Eventual.parse("del 1 al 3, marzo del '10") }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end
    end

    describe "spanning diferent months '24 de febrero al 3 de marzo del 2010" do
      before do
        @result = Eventual.parse "24 de febrero al 3 de marzo del 2010"
        @dates  = (Date.parse('2010-2-24')..Date.parse('2010-3-3'))
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end

    describe "spanning diferent years '24 de diciembre del 2009 al 3 de enero del 2010" do
      before do 
        @result = Eventual.parse("24 de diciembre del 2009 al 3 de enero del 2010")
        @dates  = (Date.parse('2009-12-24')..Date.parse('2010-1-3'))
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end

    describe 'period spanning two dates' do
      before do
        @dates = (Date.parse('2008-10-1')..DateTime.parse('2008-12-2'))
      end

      describe "1 de octubre a 2 de diciembre del 2008" do
        before { @result = Eventual.parse "1 de octubre a 2 de diciembre del 2008" }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "1 de octubre al 2 de diciembre del 2008" do
        before { @result = Eventual.parse "1 de octubre al 2 de diciembre del 2008" }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "del miercoles 1 de octubre al martes 2 de diciembre del 2008" do
        before { @result = Eventual.parse "del miercoles 1 de octubre al martes 2 de diciembre del 2008" }
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end
    end

    describe "lunes y martes del 1 de octubre al 2 de diciembre del 2008" do
      before do 
        @result = Eventual.parse "lunes y martes del 1 de octubre al 2 de diciembre del 2008"
        @dates  = (Date.parse('2008-10-1')..DateTime.parse('2008-12-2')).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end

    describe "lunes y martes, del 1 de octubre al 2 de diciembre del 2008" do
      before do 
        @result = Eventual.parse "lunes y martes, del 1 de octubre al 2 de diciembre del 2008"
        @dates  = (Date.parse('2008-10-1')..DateTime.parse('2008-12-2')).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end

    describe 'with weekday constrain' do
      describe "wdays for 'lunes y martes del 1 al 22 de marzo del '10" do
        before do 
          @result = Eventual.parse "lunes y martes del 1 al 22 de marzo del '10"
          @dates  = (Date.parse('2010-3-1')..Date.parse('2010-3-22')).reject{ |day| not [1,2].include?(day.wday) }
        end
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "wdays for 'fines de semana del 1 al 22 de marzo del '10" do
        before do
          @result = Eventual.parse "fines de semana del 1 al 22 de marzo del '10"
          @dates  = (Date.parse('2010-3-1')..Date.parse('2010-3-22')).map.reject{ |day| not [6,0].include?(day.wday) }
        end
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe "wdays for 'entre semana del 1 al 22 de marzo del '10" do
        before do 
          @result = Eventual.parse("entre semana del 1 al 22 de marzo del '10")
          @dates  = (Date.parse('2010-3-1')..Date.parse('2010-3-22')).map.reject{ |day| not (1..5).map.include?(day.wday) }
        end
        it_should_behave_like 'correctly parses dates'
        it_should_behave_like 'includes corresponding dates'
      end

      describe 'sugar for wday constrain' do
        before do
          @dates = (Date.parse('2010-3-1')..Date.parse('2010-3-22')).reject{ |day| not [1,2].include?(day.wday) }
        end

        describe "wdays for 'lunes y martes del 1 al 22 de marzo del '10" do
          before { @result = Eventual.parse("lunes y martes del 1 al 22 de marzo del '10") }
          it_should_behave_like 'correctly parses dates'
          it_should_behave_like 'includes corresponding dates'
        end

        describe "wdays for 'todos los lunes y martes del 1 al 22 de marzo del '10" do
          before { @result = Eventual.parse("todos los lunes y martes del 1 al 22 de marzo del '10") }
          it_should_behave_like 'correctly parses dates'
          it_should_behave_like 'includes corresponding dates'
        end

        describe "wdays for 'los lunes y martes del 1 al 22 de marzo del '10" do
          before { @result = Eventual.parse("los lunes y martes del 1 al 22 de marzo del '10") }
          it_should_behave_like 'correctly parses dates'
          it_should_behave_like 'includes corresponding dates'
        end

        describe "wdays for 'los lunes y los martes del 1 al 22 de marzo del '10" do
          before { @result = Eventual.parse("los lunes y los martes del 1 al 22 de marzo del '10") }
          it_should_behave_like 'correctly parses dates'
          it_should_behave_like 'includes corresponding dates'
        end
      end

      describe 'wday range' do
        before do
          @dates = (Date.parse('2010-3-1')..Date.parse('2010-3-22')).reject{ |day| not [1,2,3,4,5].include?(day.wday) }
        end
        describe "wdays for 'lunes a viernes del 1 al 22 de marzo del '10" do
          before { @result = Eventual.parse("lunes a viernes del 1 al 22 de marzo del '10") }
          it_should_behave_like 'correctly parses dates'
          it_should_behave_like 'includes corresponding dates'
        end

        describe "wdays for 'de lunes a viernes del 1 al 22 de marzo del '10" do
          before { @result = Eventual.parse("de lunes a viernes del 1 al 22 de marzo del '10") }
          it_should_behave_like 'correctly parses dates'
          it_should_behave_like 'includes corresponding dates'
        end
      end
    end
  end

  describe 'month range' do
    describe 'octubre a diciembre del 2008' do
      before do 
        @result = Eventual.parse('octubre a diciembre del 2008')
        @dates  = (Date.parse('2008-10-1')..DateTime.parse('2008-12-31')).map
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end


    describe 'lunes y martes de octubre del 2007 a diciembre del 2008' do
      before do 
        @result = Eventual.parse('lunes y martes de octubre del 2007 a diciembre del 2008')
        @dates  = (Date.parse('2007-10-1')..DateTime.parse('2008-12-31')).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end
  end

  describe 'compound dates giving year at the end' do
    before do
      @result = Eventual.parse "1 de enero y lunes y martes del 1 de octubre al 2 de diciembre del 2008"
      @dates  = [Date.parse('2008-1-1')] + (Date.parse('2008-10-1')..Date.parse('2008-12-2')).reject{ |day| not [1,2].include?(day.wday) }
    end
    it_should_behave_like 'correctly parses dates'
    it_should_behave_like 'includes corresponding dates'
  end
  
  describe 'compound dates list' do
    before do
      @result = Eventual.parse "31 de diciembre de 1998 y 1 de enero de 1999"
      @dates  = [Date.parse('1998-12-31'), Date.parse('1999-1-1')]
    end
    it_should_behave_like 'correctly parses dates'
    it_should_behave_like 'includes corresponding dates'
  end
  
  describe 'compound dates list separated by new line' do
    before do
      @result = Eventual.parse "31 de diciembre de 1998 \n 1 de enero de 1999"
      @dates  = [Date.parse('1998-12-31'), Date.parse('1999-1-1')]
    end
    it_should_behave_like 'correctly parses dates'
    it_should_behave_like 'includes corresponding dates'
  end

  describe 'with time constrain' do
    shared_examples_for 'outputs DateTime' do
      it "should all be DateTime" do
        @result.map{ |d| d.should be_a(DateTime) }
      end
    end

    describe 'single day with time' do
      before do
        @result = Eventual.parse('1 de enero del 2010 a las 15:00')
        @dates  = [DateTime.civil 2010, 1, 1, 15]
      end

      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'
    end

    describe 'single time with no sugar for month range' do
      before do
        @result = Eventual.parse('lunes y martes de diciembre del 2010 a las 15:00')
        @dates  = (DateTime.parse('2010-12-1T15:00')..DateTime.parse('2010-12-31T15:00')).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'
    end

    describe 'single time with sugar 1 for month range' do
      before do
        @result = Eventual.parse('lunes y martes de diciembre a las 15:00 hrs.')
        @dates  = (DateTime.parse('2010-12-1T15:00')..DateTime.parse('2010-12-31T15:00')).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'
    end

    describe 'single time with sugar 2 for month range' do
      before do
        @result = Eventual.parse('lunes y martes de diciembre a las 15:00hrs')
        @dates  = (DateTime.parse('2010-12-1T15:00')..DateTime.parse('2010-12-31T15:00')).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'
    end

    describe 'single time with sugar 3 for month range' do
      before do
        @result = Eventual.parse('lunes y martes de diciembre a las 15 horas')
        @dates  = (DateTime.parse('2010-12-1T15:00')..DateTime.parse('2010-12-31T15:00')).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'
    end

    describe 'two times for month range' do
      before do
        @result = Eventual.parse('lunes y martes de diciembre a las 16:00 y 15:00 horas')
        @dates  = ((DateTime.parse('2010-12-1T15:00')..DateTime.parse('2010-12-31T15:00')).map + (DateTime.parse('2010-12-1T16:00')..DateTime.parse('2010-12-31T16:00')).map).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'

      it "should not include other time" do
        @result.should_not include(DateTime.parse('2010-12-06T14:00'))
      end
    end

    describe 'three times for month range' do
      before do
        @result = Eventual.parse('lunes y martes de diciembre a las 16:00, 17:00 y 15:00 horas')
        @dates  = (
        (DateTime.parse('2010-12-1T15:00')..DateTime.parse('2010-12-31T15:00')).map + 
        (DateTime.parse('2010-12-1T16:00')..DateTime.parse('2010-12-31T16:00')).map +
        (DateTime.parse('2010-12-1T17:00')..DateTime.parse('2010-12-31T17:00')).map
        ).reject{ |day| not [1,2].include?(day.wday) }
      end

      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'

      it "should not include other time" do
        @result.should_not include(DateTime.parse('2010-12-06T14:00'))
      end
    end

    describe 'range with time as 12 hours am' do
      before do
        @result = Eventual.parse('lunes y martes de diciembre a las 3 am')
        @dates  = ((DateTime.parse('2010-12-1T03:00')..DateTime.parse('2010-12-31T03:00')).map).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'

      it "should not include other time" do
        @result.should_not include(DateTime.parse('2010-12-06T14:00'))
      end
    end

    describe 'range with time as 12 hours pm' do
      before do
        @result = Eventual.parse('lunes y martes de diciembre a las 3:00 pm')
        @dates  = ((DateTime.parse('2010-12-1T15:00')..DateTime.parse('2010-12-31T15:00')).map).reject{ |day| not [1,2].include?(day.wday) }
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'

      it "should not include other time" do
        @result.should_not include(DateTime.parse('2010-12-06T14:00'))
      end
    end

    describe 'event default timespan' do
      before do
        @result = Eventual.parse('1 de diciembre del 2010 a las 15:00')
        @dates  = [DateTime.parse('2010-12-1T15:00')]
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
      it_should_behave_like 'outputs DateTime'
    end
  end

  describe "with time range" do
    describe 'single day with time range' do
      before do
        @result = Eventual.parse('1 de enero del 2010 de las 15:00 a las 16:00')
        @ranges = [(DateTime.civil 2010, 1, 1, 15)..(DateTime.civil 2010, 1, 1, 16)]
        @dates  = @ranges.map{ |range| range.map }.flatten
      end
      
      it_should_behave_like 'correctly parses time ranges'
      it_should_behave_like 'includes corresponding dates'
    end
    
    describe 'single day with two element time range list' do
      before do
        @result = Eventual.parse('1 de enero del 2010 de las 15:00 a las 16:00 y de las 17:00 a las 19:00')
        @ranges = [(DateTime.civil 2010, 1, 1, 15)..(DateTime.civil 2010, 1, 1, 16), (DateTime.civil 2010, 1, 1, 17)..(DateTime.civil 2010, 1, 1, 19)]
        @dates  = @ranges.map{ |range| range.map }.flatten
      end
      
      it_should_behave_like 'correctly parses time ranges'
      it_should_behave_like 'includes corresponding dates'
    end
    
    describe 'single day with two element time range list' do
      before do
        @result = Eventual.parse('1 de enero del 2010 de las 15:00 a las 16:00, de las 17:00 a las 19:00 y de las 21:00 a las 22:00')
        @ranges = [(DateTime.civil 2010, 1, 1, 15)..(DateTime.civil 2010, 1, 1, 16), (DateTime.civil 2010, 1, 1, 17)..(DateTime.civil 2010, 1, 1, 19), (DateTime.civil 2010, 1, 1, 21)..(DateTime.civil 2010, 1, 1, 22)]
        @dates  = @ranges.map{ |range| range.map }.flatten
      end
      
      it_should_behave_like 'correctly parses time ranges'
      it_should_behave_like 'includes corresponding dates'
    end
  end


  describe 'Marshal dump' do
    describe "month without year parsing 'marzo'" do
      before do
        @result = Marshal.load Marshal.dump(Eventual.parse('marzo')).gsub('NaturalDates::', 'NaturalDates::Eventual::Es::')
        @dates  = (Date.parse('2010-3-1')..Date.parse('2010-3-31')).map
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end
  end

  describe 'Default year' do
    describe "month without year parsing 'marzo'" do
      before do
        @result = Eventual.parse('marzo', :default_year => 2007)
        @dates  = (Date.parse('2007-3-1')..Date.parse('2007-3-31')).map
      end
      it_should_behave_like 'correctly parses dates'
      it_should_behave_like 'includes corresponding dates'
    end
  end
end
