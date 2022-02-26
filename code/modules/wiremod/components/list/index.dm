/**
 * # Index Component
 *
 * Return the index of a list
 */
/obj/item/circuit_component/index
	display_name = "Индексатор"
	desc = "Компонент, который возвращает значение списка с заданным индексом."

	/// The input port
	var/datum/port/input/list_port
	var/datum/port/input/index_port

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/index/populate_ports()
	index_port = add_input_port("Указатель", PORT_TYPE_ANY)
	list_port = add_input_port("Список", PORT_TYPE_LIST)

	output = add_output_port("Значение", PORT_TYPE_ANY)

/obj/item/circuit_component/index/input_received(datum/port/input/port)

	var/index = index_port.value
	var/list/list_input = list_port.value

	if(!islist(list_input) || !index)
		output.set_output(null)
		return

	if(isnum(index) && (index < 1 || index > length(list_input)))
		output.set_output(null)
		return

	output.set_output(list_input[index])

