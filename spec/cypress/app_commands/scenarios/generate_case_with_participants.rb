GenerateDevDataService.new.generate_case_with_participants(
  number_of_participants: command_options.fetch("number_of_participants", 3)&.to_i,
  case_number: command_options.fetch("case_number", nil)
)
