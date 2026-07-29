class axi_agent_config extends uvm_object;

  `uvm_object_utils(axi_agent_config)

  local virtual axi_interface vif;

  local uvm_active_passive_enum active_passive;

  local bit is_check;

  function new(string name="");
    super.new(name);

    active_passive = UVM_ACTIVE;
    is_check       = 1;
  endfunction
  
  

  function uvm_active_passive_enum get_active_passive();
    return active_passive;
  endfunction

  function void set_active_passive(
      uvm_active_passive_enum value);
    active_passive = value;
  endfunction

  function bit get_is_check();
    return is_check;
  endfunction

  function void set_is_check(bit value);

    is_check = value;

    if(vif != null)
      vif.is_check = is_check;

  endfunction

  function virtual axi_interface get_vif();
    return vif;
  endfunction

  function void set_vif(
      virtual axi_interface value);

    if(vif == null) begin

      vif = value;

      set_is_check(get_is_check());

    end
    else begin

      `uvm_fatal("CFG",
                 "Trying to set vif more than once")

    end

  endfunction

endclass
