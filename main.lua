--[[
---
Projeto: Gerenciador de Tarefas em Linha de Comando (CLI)
Descrição: Uma ferramenta simples para adicionar, listar e completar tarefas diretamente
           do seu terminal. As tarefas são salvas em um arquivo `tasks.txt`
           no mesmo diretório.
Bibliotecas necessárias: Nenhuma. Utiliza apenas as bibliotecas padrão do Lua.
Como executar:
  - Para adicionar uma tarefa: lua main.lua add "Comprar pão"
  - Para listar todas as tarefas: lua main.lua list
  - Para marcar uma tarefa como feita (pelo número): lua main.lua do 2
  - Para ver a ajuda: lua main.lua help
---
--]]

local TASKS_FILE = "tasks.txt"
local tasks = {}

-- Carrega as tarefas do arquivo de texto para a memória.
-- Cada linha do arquivo tem o formato: "status|descrição" (ex: "pending|Lavar o carro")
function loadTasks()
    local file = io.open(TASKS_FILE, "r")
    if not file then
        return -- Arquivo ainda não existe, o que é normal na primeira execução.
    end

    for line in file:lines() do
        local status, description = line:match("([^|]+)|(.*)")
        if status and description then
            table.insert(tasks, {
                description = description,
                completed = (status == "done")
            })
        end
    end
    file:close()
end

-- Salva as tarefas da memória de volta para o arquivo de texto.
function saveTasks()
    local file = io.open(TASKS_FILE, "w")
    if not file then
        print("Erro: Não foi possível abrir o arquivo para escrita: " .. TASKS_FILE)
        return
    end

    for _, task in ipairs(tasks) do
        local status = task.completed and "done" or "pending"
        file:write(string.format("%s|%s\n", status, task.description))
    end
    file:close()
end

-- Adiciona uma nova tarefa à lista.
function addTask(description)
    if not description or description == "" then
        print("Erro: A descrição da tarefa não pode ser vazia.")
        return
    end
    table.insert(tasks, { description = description, completed = false })
    print("Tarefa adicionada: \"" .. description .. "\"")
    saveTasks()
end

-- Lista todas as tarefas no console com formatação.
function listTasks()
    if #tasks == 0 then
        print("Nenhuma tarefa encontrada. Adicione uma com 'lua main.lua add \"minha tarefa\"'")
        return
    end

    print("--- Sua Lista de Tarefas ---")
    for i, task in ipairs(tasks) do
        local checkbox = task.completed and "[x]" or "[ ]"
        print(string.format("%d. %s %s", i, checkbox, task.description))
    end
    print("----------------------------")
end

-- Marca uma tarefa específica como concluída.
function completeTask(index)
    local taskIndex = tonumber(index)
    if not taskIndex or taskIndex <= 0 or taskIndex > #tasks then
        print("Erro: Número da tarefa inválido. Use 'list' para ver os números corretos.")
        return
    end

    if tasks[taskIndex].completed then
        print("A tarefa #" .. taskIndex .. " já estava concluída.")
    else
        tasks[taskIndex].completed = true
        print("Tarefa #" .. taskIndex .. " marcada como concluída: \"" .. tasks[taskIndex].description .. "\"")
        saveTasks()
    end
end

-- Exibe as instruções de uso.
function showHelp()
    print([[\nUso: lua main.lua <comando> [argumentos]\n\nComandos:\n  add "descrição da tarefa"   Adiciona uma nova tarefa.\n  list                        Lista todas as tarefas.\n  do <número>                 Marca uma tarefa como concluída.\n  help                        Mostra esta mensagem de ajuda.\n]])
end

-- --- Lógica Principal ---
-- Ponto de entrada do script.

loadTasks()

local command = arg[1]
local argument = arg[2]

if command == "add" then
    addTask(argument)
elif command == "list" then
    listTasks()
elif command == "do" then
    completeTask(argument)
elif command == "help" then
    showHelp()
else
    print("Comando inválido: '" .. tostring(command) .. "'")
    showHelp()
end
