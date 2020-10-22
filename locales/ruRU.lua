local addonName = ...

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "ruRU", false)
if not L then return end

L["cfg_minimap_icon"] = "Значок на миникарте"
L["cfg_replace_macros"] = "Заменять все существующие макросы при переключении профиля"
L["cfg_settings"] = "Настройки"
L["charframe_tab"] = "Панели команд"
L["chat_share_invite"] = [=[Я отправил вам свой профиль, но у вас не установлен %s.
Пожалуйста установите %s с %s и попросите меня отправить профиль заново.]=]
L["confirm_delete"] = "Вы действительно хотите удалить профиль панелей команд \"%s\"?"
L["confirm_overwrite"] = "Профиль панелей команд с названием \"%s\" уже существует. Хотите заменить его?"
L["confirm_receive"] = "%s отправил(а) вам профиль панелей команд. Хотите сохранить его?"
L["confirm_save"] = "Хотите сохранить профиль панелей команд \"%s\"?"
L["confirm_use"] = "%s из %s действий этого профиля не могут быть использованы текущим персонажем. Хотите использовать этот профиль?"
L["error_exists"] = "Это название уже используется для другого профиля."
L["gui_new_profile"] = [=[Новый
профиль]=]
L["gui_profile_name"] = "Введите название профиля (16 символов макс.):"
L["gui_profile_options"] = "Сохранить в профиле:"
L["msg_bad_link"] = "Неверная ссылка: %s"
L["msg_cant_create_macro"] = "Не могу создать макрос: %s"
L["msg_cant_learn_talent"] = "Не могу изучить талант: %s"
L["msg_cant_place_item"] = "Не могу разместить предмет: %s"
L["msg_cant_place_macro"] = "Не могу разместить макрос: %s"
L["msg_cant_place_spell"] = "Не могу разместить заклинание: %s"
L["msg_equip_not_exists"] = "Комплект экипировки не найден: %s"
L["msg_found_by_name"] = "Найдено по имени: %s"
L["msg_macro_not_exists"] = "Макрос не найден: %s"
L["msg_pet_not_exists"] = "Питомец не найден: %s"
L["msg_profile_deleted"] = "Профиль \"%s\" удален"
L["msg_profile_list"] = "Доступные профили: %s"
L["msg_profile_list_empty"] = "Нет доступных профилей"
L["msg_profile_not_exists"] = "Профиль \"%s\" не найден"
L["msg_profile_renamed"] = "Профиль \"%s\" переименован в \"%s\""
L["msg_profile_saved"] = "Профиль \"%s\" сохранен"
L["msg_profile_updated"] = "Профиль \"%s\" обновлен"
L["msg_spell_not_exists"] = "Заклинание не найдено: %s"
L["msg_talent_not_exists"] = "Талант не найден: %s"
L["option_actions"] = "Панели команд"
L["option_bindings"] = "Назначение клавиш"
L["option_empty_slots"] = "Пустые слоты"
L["option_macros"] = "Макросы"
L["option_pet_actions"] = "Управление питомцем"
L["option_talents"] = "Таланты"
L["option_pvp_talents"] = "PvP Таланты"
L["tooltip_list"] = "Доступные профили:"
L["tooltip_list_empty"] = "Нет доступных профилей"

