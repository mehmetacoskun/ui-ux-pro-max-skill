import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Rocket, 
  CheckCircle2, 
  Users, 
  Zap, 
  BarChart3, 
  Layout, 
  ArrowRight, 
  Menu, 
  X, 
  Mail, 
  Globe, 
  MessageCircle,
  Star
} from 'lucide-react';

// Hero image path - using the one generated earlier
const HERO_IMAGE = '/astrotask_dashboard_mockup_1775728865540.png';

const App: React.FC = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.5 }
    }
  };

  return (
    <div className="min-h-screen bg-[#F0FDFA] text-[#134E4A]">
      {/* Navbar */}
      <nav className={`fixed top-4 left-4 right-4 z-50 transition-all duration-300 rounded-2xl ${scrolled ? 'glass py-3 shadow-lg' : 'bg-transparent py-5'}`}>
        <div className="container flex items-center justify-between">
          <div className="flex items-center gap-2 group cursor-pointer">
            <div className="bg-[#0D9488] p-2 rounded-xl text-white transform group-hover:rotate-12 transition-transform shadow-md">
              <Rocket size={24} />
            </div>
            <span className="text-xl font-bold tracking-tight text-[#134E4A]">AstroTask</span>
          </div>

          <div className="hidden md:flex items-center gap-8">
            <a href="#features" className="font-medium hover:text-[#0D9488]">Features</a>
            <a href="#testimonials" className="font-medium hover:text-[#0D9488]">Trust</a>
            <a href="#pricing" className="font-medium hover:text-[#0D9488]">Pricing</a>
            <button className="btn-primary">Get Started Free</button>
          </div>

          <button className="md:hidden text-[#0C4A6E]" onClick={() => setIsMenuOpen(!isMenuOpen)}>
            {isMenuOpen ? <X size={28} /> : <Menu size={28} />}
          </button>
        </div>
      </nav>

      {/* Mobile Menu */}
      <AnimatePresence>
        {isMenuOpen && (
          <motion.div 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="fixed inset-0 z-40 bg-white md:hidden pt-24 px-6"
          >
            <div className="flex flex-col gap-6 text-xl font-semibold">
              <a href="#features" onClick={() => setIsMenuOpen(false)}>Features</a>
              <a href="#testimonials" onClick={() => setIsMenuOpen(false)}>Trust</a>
              <a href="#pricing" onClick={() => setIsMenuOpen(false)}>Pricing</a>
              <button className="btn-primary w-full justify-center py-4">Get Started Free</button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Hero Section */}
      <section className="pt-32 pb-20 md:pt-48 md:pb-32 overflow-hidden">
        <div className="container">
          <motion.div 
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="text-center max-w-4xl mx-auto mb-16"
          >
            <motion.span variants={itemVariants} className="inline-block py-1.5 px-4 rounded-full bg-[#0D9488]/10 text-[#0D9488] font-bold text-sm mb-6 tracking-wide uppercase border border-[#0D9488]/20">
              The Future of Work is Here
            </motion.span>
            <motion.h1 variants={itemVariants} className="text-5xl md:text-7xl font-bold mb-8 leading-tight tracking-tight text-[#134E4A]">
              Effortless Productivity for <span className="text-gradient">Modern Teams</span>
            </motion.h1>
            <motion.p variants={itemVariants} className="text-lg md:text-xl text-gray-600 mb-10 max-w-2xl mx-auto leading-relaxed">
              The all-in-one workspace that adapts to your flow. Manage tasks, visualize progress, and collaborate seamlessly in real-time.
            </motion.p>
            <motion.div variants={itemVariants} className="flex flex-col sm:flex-row gap-4 justify-center">
              <button className="btn-primary px-10 py-4 text-lg">
                Get Started Free <ArrowRight size={20} />
              </button>
              <button className="btn-secondary px-10 py-4 text-lg">
                Watch Demo
              </button>
            </motion.div>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.5 }}
            className="relative"
          >
            <div className="absolute -inset-4 bg-gradient-to-r from-[#0D9488] to-[#F97316] rounded-[2rem] opacity-10 blur-3xl -z-10"></div>
            <img 
              src={HERO_IMAGE} 
              alt="AstroTask Dashboard Mockup" 
              className="w-full rounded-[2rem] shadow-2xl border-4 border-white/50 glass object-cover"
              style={{ maxHeight: '700px' }}
            />
          </motion.div>
        </div>
      </section>

      {/* Social Proof */}
      <section className="py-12 bg-white">
        <div className="container">
          <p className="text-center text-sm font-semibold text-gray-500 uppercase tracking-widest mb-10">
            Trusted by founders at world-class companies
          </p>
          <div className="flex flex-wrap justify-center items-center gap-12 md:gap-20 opacity-40 grayscale hover:opacity-100 hover:grayscale-0 transition-all duration-500">
            <span className="text-2xl font-black tracking-tighter">GOOGLE</span>
            <span className="text-2xl font-black tracking-tighter">META</span>
            <span className="text-2xl font-black tracking-tighter">STRIPE</span>
            <span className="text-2xl font-black tracking-tighter">AIRBNB</span>
            <span className="text-2xl font-black tracking-tighter">NOTION</span>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="section-padding bg-white">
        <div className="container">
          <div className="text-center max-w-3xl mx-auto mb-20">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Everything you need to <span className="text-gradient">ship faster</span></h2>
            <p className="text-lg text-gray-600">AstroTask combines the simplicity of lists with the power of complex databases. Built for teams that move fast.</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {[
              { 
                icon: <Layout className="text-[#0D9488]" size={32} />, 
                title: "Flexible Layouts", 
                desc: "Switch between Kanban, List, Table, and Calendar views with a single click. Your data, your way." 
              },
              { 
                icon: <Zap className="text-[#F97316]" size={32} />, 
                title: "Powerful Automations", 
                desc: "Turn manual work into auto-pilot. Set up triggers and actions to sync across your entire stack." 
              },
              { 
                icon: <Users className="text-[#0D9488]" size={32} />, 
                title: "Real-time Sync", 
                desc: "Collaborate with your team instantly. See who's online and what they're working on in real-time." 
              },
              { 
                icon: <BarChart3 className="text-[#F97316]" size={32} />, 
                title: "Deep Analytics", 
                desc: "Visualize your team's performance with beautiful, built-in charts and reporting dashboards." 
              },
              { 
                icon: <CheckCircle2 className="text-[#0D9488]" size={32} />, 
                title: "Mobile Ready", 
                desc: "Access your workspace from anywhere. Our mobile app keeps you in the loop on the go." 
              },
              { 
                icon: <Rocket className="text-[#F97316]" size={32} />, 
                title: "Fast as Light", 
                desc: "Optimized for speed. No more waiting for pages to load. AstroTask responds as fast as you think." 
              }
            ].map((f, i) => (
              <motion.div 
                key={i}
                whileHover={{ y: -8 }}
                className="p-8 rounded-2xl border border-[#0D9488]/10 bg-white hover:shadow-xl transition-all cursor-pointer group"
              >
                <div className="mb-6 p-4 rounded-xl bg-white w-fit shadow-sm">{f.icon}</div>
                <h3 className="text-xl font-bold mb-4">{f.title}</h3>
                <p className="text-gray-600 leading-relaxed">{f.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section id="testimonials" className="section-padding overflow-hidden">
        <div className="container">
          <div className="text-center mb-20">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Loved by thousands of <span className="text-gradient">builders</span></h2>
            <div className="flex justify-center gap-1 mb-4">
              {[...Array(5)].map((_, i) => <Star key={i} className="text-orange-400 fill-orange-400" size={20} />)}
            </div>
            <p className="text-gray-600">Rated 4.9/5 stars by 10,000+ teams worldwide.</p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              {
                text: "AstroTask has completely transformed how our engineering team works. We shipped 20% faster in the first month alone.",
                author: "Sarah Jenkins",
                role: "CTO at TechFlow"
              },
              {
                text: "The cleanest UI I've ever used. It's rare to find a tool that is both powerful and actually pleasant to look at every day.",
                author: "Marcus Chen",
                role: "Lead Designer at Pixel"
              },
              {
                text: "We tried everything from Jira to Notion, but AstroTask is the first tool that actually fits our unique workflow perfectly.",
                author: "Elena Rodriguez",
                role: "Product Manager at Swift"
              }
            ].map((t, i) => (
              <motion.div 
                key={i}
                className="p-8 glass rounded-2xl shadow-lg relative"
              >
                <p className="text-lg italic mb-6">"{t.text}"</p>
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#0D9488] to-[#F97316]"></div>
                  <div>
                    <h4 className="font-bold">{t.author}</h4>
                    <span className="text-sm text-gray-500">{t.role}</span>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section id="pricing" className="section-padding bg-white">
        <div className="container">
          <div className="text-center mb-20">
            <h2 className="text-4xl md:text-5xl font-bold mb-6">Simple, <span className="text-gradient">transparent</span> pricing</h2>
            <p className="text-lg text-gray-600">Start for free and scale as your team grows. No hidden fees.</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            <div className="p-8 rounded-3xl border border-gray-100 flex flex-col">
              <h3 className="text-xl font-bold mb-2">Starter</h3>
              <div className="mb-6"><span className="text-4xl font-bold">$0</span><span className="text-gray-500">/mo</span></div>
              <ul className="space-y-4 mb-10 flex-grow">
                <li className="flex items-center gap-2"><CheckCircle2 className="text-green-500" size={18} /> Up to 5 users</li>
                <li className="flex items-center gap-2"><CheckCircle2 className="text-green-500" size={18} /> Basic workflows</li>
                <li className="flex items-center gap-2"><CheckCircle2 className="text-green-500" size={18} /> 1GB Storage</li>
              </ul>
              <button className="btn-secondary w-full justify-center">Get Started</button>
            </div>

            <div className="p-10 rounded-3xl bg-[#134E4A] text-white shadow-2xl scale-105 relative z-10 flex flex-col border border-[#0D9488]/30">
              <div className="absolute top-0 right-10 transform -translate-y-1/2 bg-[#F97316] text-white text-xs font-bold px-3 py-1 rounded-full uppercase">Most Popular</div>
              <h3 className="text-xl font-bold mb-2">Pro Team</h3>
              <div className="mb-6"><span className="text-5xl font-bold">$12</span><span className="text-gray-400">/user/mo</span></div>
              <ul className="space-y-4 mb-10 flex-grow">
                <li className="flex items-center gap-2"><CheckCircle2 className="text-[#0D9488]" size={18} /> Unlimited users</li>
                <li className="flex items-center gap-2"><CheckCircle2 className="text-[#0D9488]" size={18} /> Advanced automations</li>
                <li className="flex items-center gap-2"><CheckCircle2 className="text-[#0D9488]" size={18} /> Unlimited storage</li>
                <li className="flex items-center gap-2"><CheckCircle2 className="text-[#0D9488]" size={18} /> Custom dashboards</li>
              </ul>
              <button className="btn-primary w-full justify-center py-4">Start 14-Day Trial</button>
            </div>

            <div className="p-8 rounded-3xl border border-gray-100 flex flex-col">
              <h3 className="text-xl font-bold mb-2">Enterprise</h3>
              <div className="mb-6"><span className="text-4xl font-bold">Custom</span></div>
              <ul className="space-y-4 mb-10 flex-grow">
                <li className="flex items-center gap-2"><CheckCircle2 className="text-green-500" size={18} /> Everything in Pro</li>
                <li className="flex items-center gap-2"><CheckCircle2 className="text-green-500" size={18} /> SSO & Governance</li>
                <li className="flex items-center gap-2"><CheckCircle2 className="text-green-500" size={18} /> High-priority support</li>
                <li className="flex items-center gap-2"><CheckCircle2 className="text-green-500" size={18} /> Onsite training</li>
              </ul>
              <button className="btn-secondary w-full justify-center">Contact Sales</button>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Climax */}
      <section className="section-padding">
        <div className="container">
          <div className="bg-[#0D9488] rounded-[3rem] p-12 md:p-20 text-center text-white relative overflow-hidden shadow-2xl">
            <div className="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full -mr-32 -mt-32"></div>
            <div className="absolute bottom-0 left-0 w-64 h-64 bg-black/10 rounded-full -ml-32 -mb-32"></div>
            
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              whileInView={{ scale: 1, opacity: 1 }}
              transition={{ duration: 0.6 }}
              className="relative z-10"
            >
              <h2 className="text-4xl md:text-6xl font-bold mb-8">Ready to boost your <br /> team's productivity?</h2>
              <p className="text-xl text-blue-100 mb-12 max-w-2xl mx-auto">Join 10,000+ teams who are already building the future with AstroTask. No credit card required.</p>
              <button className="bg-white text-[#0D9488] cursor-pointer hover:bg-gray-100 px-10 py-4 rounded-xl font-bold text-xl transition-all shadow-xl hover:shadow-2xl hover:-translate-y-1">
                Start Your Free Trial
              </button>
              <p className="mt-6 text-blue-200 text-sm">Free forever for individuals. Upgrade anytime.</p>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-20 bg-white border-t border-gray-100">
        <div className="container">
          <div className="grid md:grid-cols-4 gap-12 mb-20">
            <div className="col-span-1 md:col-span-1">
              <div className="flex items-center gap-2 mb-6">
                <div className="bg-[#0D9488] p-2 rounded-xl text-white">
                  <Rocket size={20} />
                </div>
                <span className="text-xl font-bold tracking-tight text-[#134E4A]">AstroTask</span>
              </div>
              <p className="text-gray-500 mb-8 max-w-xs">Building the workspace of the future for the teams of today.</p>
              <div className="flex gap-4">
                <a href="#" className="p-2 bg-white rounded-lg hover:text-[#0D9488] shadow-sm"><Mail size={20} /></a>
                <a href="#" className="p-2 bg-white rounded-lg hover:text-[#0D9488] shadow-sm"><Globe size={20} /></a>
                <a href="#" className="p-2 bg-white rounded-lg hover:text-[#0D9488] shadow-sm"><MessageCircle size={20} /></a>
              </div>
            </div>
            
            <div>
              <h4 className="font-bold mb-6 uppercase text-xs tracking-widest text-gray-400">Product</h4>
              <ul className="space-y-4 text-gray-600">
                <li><a href="#" className="hover:text-[#0EA5E9]">Features</a></li>
                <li><a href="#" className="hover:text-[#0EA5E9]">Integrations</a></li>
                <li><a href="#" className="hover:text-[#0EA5E9]">Pricing</a></li>
                <li><a href="#" className="hover:text-[#0EA5E9]">Changelog</a></li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold mb-6 uppercase text-xs tracking-widest text-gray-400">Company</h4>
              <ul className="space-y-4 text-gray-600">
                <li><a href="#" className="hover:text-[#0EA5E9]">About Us</a></li>
                <li><a href="#" className="hover:text-[#0EA5E9]">Blog</a></li>
                <li><a href="#" className="hover:text-[#0EA5E9]">Careers</a></li>
                <li><a href="#" className="hover:text-[#0EA5E9]">Contact</a></li>
              </ul>
            </div>

            <div>
              <h4 className="font-bold mb-6 uppercase text-xs tracking-widest text-gray-400">Legal</h4>
              <ul className="space-y-4 text-gray-600">
                <li><a href="#" className="hover:text-[#0EA5E9]">Privacy Policy</a></li>
                <li><a href="#" className="hover:text-[#0EA5E9]">Terms of Service</a></li>
                <li><a href="#" className="hover:text-[#0EA5E9]">Cookie Policy</a></li>
              </ul>
            </div>
          </div>
          
          <div className="pt-10 border-t border-gray-100 text-center text-gray-400 text-sm">
            <p>&copy; {new Date().getFullYear()} AstroTask Inc. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default App;
