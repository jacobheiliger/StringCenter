const express = require('express');
const Post = require('../../../models/post');
const Tab = require('../../../models/tabModel');

/**
 * Get all posts created by username or the currently authenticated user
 * if username isn't passed
 * @param  {Passport}      passport Authentication
 * @param  {HttpRequest}   req  url: /api/get-post/by-user/:username
 * @param  {HttpResponse}  res
 * @param  {Function}      next
 * @return {Post}          List of posts
 */
module.exports.getPostsForUser = function getPost(passport) {
    let router = express.Router();
    const pageSize = 100;

    router.get('/current/:page?', passport.authenticate('jwt', {session: false}), function (req, res, next) {
        let page = req.params.page;
        if (!page) {
            page = 1;
        }
        Post
            .find({authorUsername: req.user.username})
            .limit(pageSize)
            .skip(pageSize * (page - 1))
            .exec(function (error, posts) {
                if (error) {
                    return res.json({errors: [{message: 'Something went wrong'}]}).status(500);
                } else if (posts.length === 0) {
                    return res.json({errors: [{message: 'No posts found'}]}).status(400);
                }
                posts.sort(function (a, b) {
                    // sort by most recent dateCreated
                    return new Date(b.dateCreated) - new Date(a.dateCreated);
                });
                posts.forEach(function (p, i) {
                    Tab.findById(p.tabId, function (error, tab) {
                        if (error) {
                            return res.json({errors: [{message: 'Something went wrong'}]}).status(500);
                        } else if (tab) {
                            p.tab = tab;
                        }

                        if (i === posts.length - 1) {
                            return res.json({posts: posts}).status(200);
                        }
                    });
                });
            });
    });

    router.get('/by-name/:username/:page?', passport.authenticate('jwt', {session: false}), function (req, res, next) {
        let page = req.params.page;
        if (!page) {
            page = 1;
        }
        Post
            .find({authorUsername: req.params.username})
            .limit(pageSize)
            .skip(pageSize * (page - 1))
            .exec(function (error, posts) {
                if (error) {
                    return res.json({errors: [{message: 'Something went wrong'}]}).status(500);
                } else if (posts.length === 0) {
                    return res.json({errors: [{message: 'No posts found'}]}).status(400);
                }
                posts.sort(function (a, b) {
                    // sort by most recent dateCreated
                    return new Date(b.dateCreated) - new Date(a.dateCreated);
                });
                posts.forEach(function (p, i) {
                    Tab.findById(p.tabId, function (error, tab) {
                        if (error) {
                            return res.json({errors: [{message: 'Something went wrong'}]}).status(500);
                        } else if (tab) {
                            p.tab = tab;
                        }

                        if (i === posts.length - 1) {
                            return res.json({posts: posts}).status(200);
                        }
                    });
                });
            });
    });

    return router;
};

/**
 * Get post by id
 * @param  {Passport}      passport Authentication
 * @param  {HttpRequest}   req  url: /api/get-post/by-id/:id
 * @param  {HttpResponse}  res
 * @param  {Function}      next
 * @return {Post}
 */
module.exports.getPostById = function(passport) {
    let router = express.Router();

    router.get('/:id', passport.authenticate('jwt', { session: false }), function(req, res, next) {
        Post.findById(req.params.id, function(error, post) {
            if (error) {
                return res.json({ errors: [{ message: 'Something went wrong' }] }).status(500);
            } else if (!post) {
                return res.json({ errors: [{ message: 'Post not found' }] }).status(400);
            }
            res.json(post).status(200);
        });
    });

    return router;
};