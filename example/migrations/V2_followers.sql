-- entity: FollowerEntity
CREATE TABLE IF NOT EXISTS tb_followers (
    follower_id UUID NOT NULL,
    following_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fkuser_followers FOREIGN KEY (follower_id) REFERENCES tb_users (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fkuser_following FOREIGN KEY (following_id) REFERENCES tb_users (id) ON DELETE CASCADE ON UPDATE CASCADE
);