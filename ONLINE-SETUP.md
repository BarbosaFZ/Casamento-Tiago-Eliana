# Publicar o gestor online com dados partilhados

A aplicação continua a funcionar localmente até a configuração cloud estar completa. Para publicar uma versão partilhada:

1. Cria um projeto Supabase e copia o Project URL e a publishable key para `supabase-config.js`. Esta chave pública pode estar no site; nunca uses a `service_role` key no browser.
2. Executa `supabase-schema.sql` no SQL Editor do projeto.
3. Em Authentication, desativa o registo público e cria/convida apenas as duas contas que vão usar o gestor.
4. Depois de as contas existirem, obtém os respetivos UUIDs na lista de utilizadores e insere-os em `public.wedding_members`, por exemplo:
   `insert into public.wedding_members (user_id) values ('UUID_DO_TIAGO'), ('UUID_DA_ELIANA');`
5. Liga o repositório a GitHub Pages usando o workflow em `.github/workflows/pages.yml`. O site publica em cada atualização da branch `main`. Depois da primeira publicação, configura no Supabase o URL do site publicado como Site URL e URL de redirecionamento autorizado.

O acesso à tabela partilhada é controlado por Row Level Security e pela lista de membros. Não publicar antes de verificar as políticas e convidar apenas as contas pretendidas. A primeira vez que uma pessoa autorizada entrar, a aplicação pergunta se quer copiar os dados que já estão guardados no navegador para a base de dados partilhada; essa cópia só acontece após confirmação.

O URL público só é criado pelo GitHub depois de o repositório existir e a publicação concluir. A pasta atual ainda não está ligada a um repositório ou conta cloud.
