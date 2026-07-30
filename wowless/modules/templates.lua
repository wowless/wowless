return function(xmleval)
  return {
    CreateUIObject = xmleval.CreateUIObject,
    frames = xmleval.frames,
    GetTemplateInfo = xmleval.GetTemplateInfo,
    GetTemplateOrThrow = xmleval.GetTemplateOrThrow,
    LoadFile = xmleval.LoadFile,
    SetTemplate = xmleval.SetTemplate,
  }
end
