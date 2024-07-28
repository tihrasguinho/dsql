-- entity: FollowerEntity
CREATE TABLE IF NOT EXISTS tb_followers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL,
    following_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_follower FOREIGN KEY (follower_id) REFERENCES tb_users (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_following FOREIGN KEY (following_id) REFERENCES tb_users (id) ON DELETE CASCADE ON UPDATE CASCADE
);