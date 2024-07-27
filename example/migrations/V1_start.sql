-- entity: UserEntity
CREATE TABLE IF NOT EXISTS tb_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  name VARCHAR(255) NOT NULL,
  username VARCHAR(24) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  image VARCHAR(255),
  bio VARCHAR(255),
  website VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT NOW (),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW ()
);

-- entity: PostEntity
CREATE TABLE IF NOT EXISTS tb_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  post_id UUID,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  owner_id UUID NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW (),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW (),
  CONSTRAINT fk_post_replies FOREIGN KEY (post_id) REFERENCES tb_posts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_posts FOREIGN KEY (owner_id) REFERENCES tb_users (id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- entity: LikeEntity
CREATE TABLE IF NOT EXISTS tb_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
  post_id UUID NOT NULL,
  user_id UUID NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW (),
  CONSTRAINT fk_post_likes FOREIGN KEY (post_id) REFERENCES tb_posts (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_likes FOREIGN KEY (user_id) REFERENCES tb_users (id) ON DELETE CASCADE ON UPDATE CASCADE
);