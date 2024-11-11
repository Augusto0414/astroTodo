<script lang="ts">
  import { onMount } from "svelte";
  import { writable } from "svelte/store";
  import axios from "axios";
  import { API_BASE_URL } from "../config.ts";

  interface Todo {
    id: string;
    title: string;
    description: string;
    completed: boolean;
  }

  const todos = writable<Todo[]>([]);
  let newTodo: Todo = { id: "", title: "", description: "", completed: false };

  async function fetchTodos() {
    try {
      const response = await axios.get(`${API_BASE_URL}/todo`);
      todos.set(response.data);
    } catch (error) {
      console.error("Error al obtener tareas:", error);
    }
  }

  async function addTodo() {
    if (!newTodo.title || !newTodo.description) {
      alert("El título y la descripción son obligatorios.");
      return;
    }

    try {
      const response = await axios.post(`${API_BASE_URL}/todo`, {
        title: newTodo.title,
        description: newTodo.description,
        completed: newTodo.completed,
      });

      if (response.status === 201) {
        console.log("Tarea agregada con éxito:", response.data);
        newTodo = { id: "", title: "", description: "", completed: false };
        fetchTodos();
      } else {
        console.error("Error al agregar la tarea:", response);
        alert("Hubo un error al agregar la tarea.");
      }
    } catch (error) {
      console.error("Error al enviar la tarea:", error);
      alert("Hubo un error al enviar la tarea. Verifica la consola.");
    }
  }

  async function toggleTodoCompletion(id: string, completed: boolean) {
    if (!id) return;

    try {
      const todoToUpdate = $todos.find((todo) => todo.id === id);
      if (!todoToUpdate) return;

      const updatedTodo = {
        ...todoToUpdate,
        completed: !completed,
      };

      const response = await axios.put(`${API_BASE_URL}/todo/${id}`, updatedTodo);

      if (response.status === 200) {
        fetchTodos();
      } else {
        console.error("Error al actualizar el estado de la tarea:", response);
        alert("Hubo un error al actualizar la tarea.");
      }
    } catch (error) {
      console.error("Error al actualizar el estado de la tarea:", error);
      alert("Hubo un error al actualizar el estado de la tarea.");
    }
  }

  async function deleteTodo(id: string | undefined) {
    if (!id) return;

    try {
      await axios.delete(`${API_BASE_URL}/todo/${id}`);
      fetchTodos();
    } catch (error) {
      console.error("Error al eliminar la tarea:", error);
    }
  }

  onMount(fetchTodos);
</script>

<div class="todo-app max-w-lg mx-auto bg-white p-8 rounded-lg shadow-xl mt-8">
  <h1 class="text-4xl font-bold text-center mb-8 text-gray-800">Mis Tareas</h1>

  <form on:submit|preventDefault={addTodo} class="mb-8 space-y-4">
    <div>
      <input
        bind:value={newTodo.title}
        placeholder="Título"
        class="w-full p-4 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-lg"
      />
    </div>
    <div>
      <input
        bind:value={newTodo.description}
        placeholder="Descripción"
        class="w-full p-4 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-lg"
      />
    </div>
    <div>
      <button
        type="submit"
        class="w-full p-4 bg-blue-600 text-white font-semibold rounded-lg shadow-md hover:bg-blue-700 transition duration-200"
      >
        Agregar TODO
      </button>
    </div>
  </form>

  <!-- Lista de tareas -->
  <ul class="space-y-6">
    {#each $todos as todo (todo.id)}
      <li
        class="todo-item flex justify-between items-center bg-gray-50 p-6 rounded-lg shadow-md hover:bg-gray-100 transition duration-300"
      >
        <div class="flex flex-col">
          <!-- Solo tachar el texto de la tarea -->
          <span class="text-lg font-semibold text-gray-800" class:line-through={todo.completed}>
            {todo.title}
          </span>
          <span class="text-sm text-gray-500" class:line-through={todo.completed}>
            {todo.description}
          </span>
        </div>

        <div class="flex space-x-4 items-center">
          <!-- Checkbox para marcar como completa/incompleta -->
          <input
            type="checkbox"
            bind:checked={todo.completed}
            on:change={() => toggleTodoCompletion(todo.id)}
            class="h-6 w-6 text-blue-500 cursor-pointer"
          />

          <!-- Botón para eliminar tarea (NO tachado) -->
          <button
            on:click={() => deleteTodo(todo.id)}
            class="px-5 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition duration-200"
          >
            Eliminar
          </button>
        </div>
      </li>
    {/each}
  </ul>
</div>

<style>
  .line-through {
    text-decoration: line-through;
    color: #6b7280; /* Color gris para tareas completadas */
  }
</style>
