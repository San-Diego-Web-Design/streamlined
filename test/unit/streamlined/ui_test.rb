require File.join(File.dirname(__FILE__), '../../test_helper')
require 'streamlined/ui'

class RelevanceModuleHelpersTest < Test::Unit::TestCase
  def setup
    @inst = Relevance::ModuleHelper 
  end
  def test_reader_from_options
    assert_equal("@foo", @inst.reader_from_options("foo"))
    assert_equal("defined?(@foo) ? @foo : []", @inst.reader_from_options("foo", :default=>[]))
  end
end

class Streamlined::UITest < Test::Unit::TestCase
  
  def setup
    @ui = Class.new(Streamlined::UI)
  end
  
  class Test; end
  class TestUI; end
  class TestWithout; end
  
  def test_style_class_for_with_empty_style_classes_hash
    assert_equal({}, @ui.style_classes)
    assert_nil @ui.style_class_for(:list, :cell, nil)
  end
  
  def test_style_class_for_with_string
    flexmock(@ui).should_receive(:style_classes).and_return(:list => { :cell => "color: red" })
    assert_equal "color: red", @ui.style_class_for(:list, :cell, nil)
    assert_nil @ui.style_class_for(:list, :row, nil)
  end
  
  def test_style_class_for_with_proc
    flexmock(@ui).should_receive(:style_classes).and_return(:list => { :cell => Proc.new { |i| i.style }})
    item = flexmock(:style => "color: black")
    assert_equal "color: black", @ui.style_class_for(:list, :cell, item)
  end
  
  def test_generic_ui
    assert_equal Streamlined::UI::Generic, Streamlined::UI.generic_ui
  end
  
  def test_get_ui
    assert_equal TestUI, Streamlined::UI.get_ui(Test.name)
    assert_equal Streamlined::UI::Generic, Streamlined::UI.get_ui(TestWithout.name)
  end
  
  def test_declarative_setting_inheritance
    @ui.table_row_buttons = :trb_one
    @ui.quick_delete_button = :qdb_one
    @ui.quick_edit_button = :qeb_one
    subclass = Class.new(@ui)
    assert_equal :trb_one, subclass.table_row_buttons
    assert_equal :qdb_one, subclass.quick_delete_button
    assert_equal :qeb_one, subclass.quick_edit_button
    @ui.table_row_buttons = :trb_two
    @ui.quick_delete_button = :qdb_two
    @ui.quick_edit_button = :qeb_two
    assert_equal :trb_one, subclass.table_row_buttons
    assert_equal :trb_two, @ui.table_row_buttons
    assert_equal :qdb_one, subclass.quick_delete_button
    assert_equal :qdb_two, @ui.quick_delete_button
    assert_equal :qeb_one, subclass.quick_edit_button
    assert_equal :qeb_two, @ui.quick_edit_button
  end
  
  def test_read_only
    assert_equal nil, @ui.read_only
    assert_equal true, @ui.read_only(true)
    assert_equal true, @ui.read_only
  end
  
  def test_pagination
    assert_equal true, @ui.pagination
    assert_equal "foo", @ui.pagination("foo")
    assert_equal "foo", @ui.pagination
    assert_equal "bar", @ui.pagination="bar"
    assert_equal "bar", @ui.pagination
    assert_false @ui.pagination=false
    assert_false @ui.pagination
  end
  
  def test_model
    flexstub(@ui).should_receive(:default_model).and_return(Class)
    assert_equal Class, @ui.model
    assert_equal String, @ui.model(:string)
    assert_equal String, @ui.model
    assert_equal Fixnum, @ui.model("Fixnum")
    assert_equal Fixnum, @ui.model
  end
  
  # def test_column_header
  #   assert_equal '', @ui.column_header(nil)
  #   column = flexmock('column')
  #   column.should_receive(:name).and_return('ColumnName')
  #   column.should_receive(:human_name).and_return('Column name')
  #   
  #   assert_equal("Column name", @ui.column_header(column))
  #   
  #   @ui.column_headers(:headers => {'NoSuchColumn' => 'no such column'})
  #   
  #   assert_equal("Column name", @ui.column_header(column))
  #   
  #   column = flexmock('column')
  #   column.should_receive(:name).and_return('ColumnName')
  #   @ui.column_headers(:headers => {:ColumnName => 'a custom name'})
  #   assert_equal("a custom name", @ui.column_header(column))
  #   
  # end
    
  def test_new_submit_button
    assert_equal true, @ui.new_submit_button[:ajax]
    assert_equal false, @ui.new_submit_button({:ajax => false})[:ajax]
    assert_equal false, @ui.new_submit_button[:ajax]
  end
  
  def test_edit_submit_button
    assert_equal true, @ui.edit_submit_button[:ajax]
    assert_equal false, @ui.edit_submit_button({:ajax => false})[:ajax]
    assert_equal false, @ui.edit_submit_button[:ajax]
  end
  
  def test_header_and_footer_partials_have_defaults
    assert_equal({}, @ui.header_partials)
    assert_equal({}, @ui.footer_partials)
  end
  
  def test_custom_columns_group
    first_name = flexmock(:name => :first_name)
    last_name = flexmock(:name => :last_name)
    flexmock(Class).should_receive(:columns).and_return([first_name, last_name]).once
    flexmock(@ui).should_receive(:default_model).and_return(Class).at_least.once
    @ui.custom_columns_group(:group, :first_name, :last_name)
    assert_equal 2, @ui.custom_columns_group(:group).size
  end

  def test_required_columns
    required_col = flexmock("column")
    required_col.should_receive(:validates_presence_of?).and_return(true).once

    optional_col = flexmock("column")
    optional_col.should_receive(:validates_presence_of?).and_return(false).once

    flexmock(@ui).should_receive(:all_columns).and_return([required_col, optional_col]).once
    assert_equal [required_col], @ui.required_columns
  end
  
  def test_quick_add_columns_with_args
    flexmock(@ui).should_receive(:convert_args_to_columns).and_return(:return_val).once
    assert_equal :return_val, @ui.quick_add_columns(:anything)
  end

  def test_quick_add_columns_with_no_args
    addition = flexmock("addition")
    addition.should_receive(:is_a?).and_return(true).once
    flexmock(@ui).should_receive(:user_columns).and_return([:anything, addition]).once
    assert_equal [:anything], @ui.quick_add_columns
  end
end
