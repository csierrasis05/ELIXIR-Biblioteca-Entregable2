defmodule Library do
  defstruct books: [], users: []
  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: []
  end

  def add_book(%Library{books: books} = library, %Book{} = book) do
    %{library | books: books ++ [book]}
  end

  def add_user(%Library{users: lusers} = users, %User{} = user) do
    %{users | users: lusers ++ [user]}
  end

  def borrow_book( %Library{books: books} = library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(books, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(books, fn b
                                          when b.isbn == isbn -> updated_book
                                          b -> b
                                        end
                                  )

        updated_users = Enum.map(users, fn  u
                                          when u.id == user_id -> updated_user
                                          u -> u
                                        end
                                )

        {:ok, updated_library, updated_users}
    end
  end

  def return_book(%Library{books: books} = library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(books, fn  b
                                              when b.isbn == isbn -> updated_book
                                              b -> b
                                            end
                                  )

        updated_users = Enum.map(users, fn u
                                          when u.id == user_id -> updated_user
                                          u -> u
                                        end
                                )

        {:ok, updated_library, updated_users}
    end
  end

  def list_books(%Library{books: books} = library) do
    IO.puts("Lista de Libros --------------------------------¬")
    Enum.each(books, fn book ->
      IO.puts("Titulo: #{book.title} - Autor: #{book.author} - ISBN: #{book.isbn} - Disponible: #{if book.available, do: "Si", else: "No"}")
    end
    )
  end

  def list_users(%Library{users: users} = library) do
    IO.puts("Lista de Usuarios --------------------------------¬")
    Enum.each(users, fn user ->
      IO.puts("Nombre: #{user.name} - Id Usuario : #{user.id}")
    end
    )
  end

  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  def books_avalible(library) do
    books = Enum.filter(library.books, &(&1.available == true))
    if books, do: books, else: []
  end

  def books_avalible_by_isbn(library, isbn) do
    book = Enum.find(library.books, &(&1.isbn == isbn))
    if book.available, do: "Libro Disponible", else: "Libro no Disponible"
  end

  def find_book_by_title(library, title) do
    book = Enum.find(library.books, &(&1.title == title))
    if book, do: {:ok, book}, else: {:error, "Libro no encontrado"}
  end

  def rename_book(library, titleold, titlenew) do
      case find_book_by_title(library, titleold) do
          {:ok, book} ->
              updated_book = %Book{book | title: titlenew}
              updated_library = Enum.map(library.books, fn  b
                                                when b.title == titleold -> updated_book
                                                b -> b
                                              end
                                    )
          {:error, error} -> IO.puts(error)
      end
  end

  def run() do
    library = %Library{}
    loop(library)
  end

 defp loop(library) do
    IO.puts("""
    -------------------------------------------------¬
    Gestor de Biblioteca
    1. Agregar libro
    2. Agregar usuario
    3. Prestar libro
    4. Devolver libro
    5. Listar libros
    6. Listar usuarios
    7. Listar libros prestados por usuario
    8. Listar libros disponibles
    9. Listar libros disponibles por ISBN
    10. Renombrar libro
    11. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("\n Ingrese el titulo del libro: ")
        title = IO.gets("") |> String.trim()
        IO.write("\n Ingrese el autor del libro: ")
        autor = IO.gets("") |> String.trim()
        IO.write("\n Ingrese isbn del libro: ")
        isbn = IO.gets("") |> String.trim()
        library = add_book(library, %Book{title: title, author: autor, isbn: isbn, available: true})
        loop(library)

      2 ->
        IO.write("\n Ingrese el nombre del usuario: ")
        name = IO.gets("") |> String.trim()
        IO.write("\n Ingrese el id del usuario: ")
        id = IO.gets("") |> String.trim()
        library = add_user(library, %User{name: name, id: id, borrowed_books: []})
        loop(library)

      3 ->
        IO.write("\n Ingrese el Id del usuario: ")
        userid = IO.gets("") |> String.trim()
        IO.write("\n Ingrese el isbn del Libro: ")
        isbn = IO.gets("") |> String.trim()
        case Library.borrow_book(library, library.users, userid, isbn) do
          {:ok, updated_library, updated_users} ->
            library = %Library{books: updated_library, users: updated_users}
            loop(library)
          {:error, error_message} ->
            IO.puts("********SE PRESENTO EL SEGUIENTE ERROR********")
            IO.puts("Error: #{error_message}")
            loop(library)
        end

      4 ->
        IO.write("\n Ingrese el Id del usuario: ")
        userid = IO.gets("") |> String.trim()
        IO.write("\n Ingrese el isbn del Libro: ")
        isbn = IO.gets("") |> String.trim()
        case Library.return_book(library, library.users, userid, isbn) do
          {:ok, updated_library, updated_users} ->
            library = %Library{books: updated_library, users: updated_users}
            loop(library)
          {:error, error_message} ->
            IO.puts("********SE PRESENTO EL SEGUIENTE ERROR********")
            IO.puts("Error: #{error_message}")
            loop(library)
        end

      5 ->
        list_books(library)
        loop(library)

      6 ->
        list_users(library)
        loop(library)

      7 ->
        IO.write("\n Ingrese el Id del usuario: ")
        userid = IO.gets("") |> String.trim()
        books = books_borrowed_by_user(library.users, userid)
        IO.puts("Libros prestados por el usuario #{userid} --------------------------------¬")
        Enum.each(books, fn book ->
          IO.puts("Titulo: #{book.title} - Autor: #{book.author} - ISBN: #{book.isbn}")
        end
        )
        loop(library)

      8 ->
        books = books_avalible(library)
        if books == [] do
          IO.puts("NO HAY LIBROS DISPONIBLES --------------------------------¬")
          loop(library)
        else
          IO.puts("Libros Disponibles --------------------------------¬")
          Enum.each(books, fn book ->
            IO.puts("Titulo: #{book.title} - Autor: #{book.author} - ISBN: #{book.isbn}")
          end
          )
          loop(library)
        end

      9 ->
        IO.write("\n Ingrese el isbn del Libro: ")
        isbn = IO.gets("") |> String.trim()
        books_avalible_by_isbn(library, isbn)
        loop(library)

      10 ->#rename_book(library, titleold, titlenew)
        IO.write("\n Ingrese el nombre del libro: ")
        bold = IO.gets("") |> String.trim()
        IO.write("\n Ingrese el nuevo nombre del libro: ")
        bnew = IO.gets("") |> String.trim()
        rename_book(library, bold, bnew)
        loop(library)

      11 ->
        IO.puts("¡Adiós - vuelva pronto!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(library)
    end
  end

end

Library.run()

#l = %Library{}
#l = Library.add_book(l, %Library.Book{title: "Libro 1", author: "Autor 1", isbn: "lbl1"})
#l = Library.add_book(l, %Library.Book{title: "Libro 2", author: "Autor 2", isbn: "lbl2"})
#l = Library.add_book(l, %Library.Book{title: "Libro 3", author: "Autor 3", isbn: "lbl3"})
#l = Library.add_user(l, %Library.User{name: "Usuario 1", id: "1"})
#l = Library.add_user(l, %Library.User{name: "Usuario 2", id: "2"})
#l = Library.borrow_book(l, l.users, "1", "lbl2")
#{:ok, updated_library, updated_users} = Library.borrow_book(l, l.users, "1", "lbl2")
#l = %Library{books: updated_library, users: updated_users}
#l = Library.return_book(l, l.users, "1", "lbl2")