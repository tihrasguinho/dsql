-- entity: UserEntity
CREATE TABLE IF NOT EXISTS tb_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  username VARCHAR(24) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  image VARCHAR(255),
  bio VARCHAR(255),
  website VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- entity: PostEntity
CREATE TABLE IF NOT EXISTS tb_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES tb_posts (id),
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  owner_id UUID NOT NULL REFERENCES tb_users (id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- entity: LikeEntity
CREATE TABLE IF NOT EXISTS tb_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES tb_posts (id),
  user_id UUID NOT NULL REFERENCES tb_users (id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
