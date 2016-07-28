function dicefg_actuator(metric, dicefg_disp)
switch metric.Handler
    case 'uml-marte'
        dicefg_disp(2,'Switching to UML MARTE update handler.')
        dicefg_disp(2,sprintf('Saving metric "%s" at "%s"',metric.Class,metric.Resource));
        dicefg_handler_umlmarte(metric, dicefg_disp);
end
end